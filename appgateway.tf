
data "azurerm_subnet" "web_ingress_subnet" {
  count                = (var.web_ingress_enabled && var.ingress_subnet_name_new != "") ? 1 : 0
  #count                = (var.web_ingress_enabled) ? 1 : 0
  name                 = var.ingress_subnet_name
  virtual_network_name = data.azurerm_virtual_network.web_ingress_vnet[0].name
  resource_group_name  = var.ingress_network_rg_name
}
data "azurerm_virtual_network" "web_ingress_vnet" {
  count               = (var.web_ingress_enabled && var.ingress_subnet_name_new != "") ? 1 : 0
  #count               = (var.web_ingress_enabled) ? 1 : 0
  name                = var.virtual_network_name
  resource_group_name = var.ingress_network_rg_name
}

data "azurerm_subnet" "web_ingress_subnet_new" {
  count                = (var.web_ingress_enabled && var.ingress_subnet_name_new != "") ? 1 : 0
  name                 = var.ingress_subnet_name_new
  virtual_network_name = data.azurerm_virtual_network.web_ingress_vnet_new[0].name
  resource_group_name  = var.ingress_network_rg_name_new
}
data "azurerm_virtual_network" "web_ingress_vnet_new" {
  count               = (var.web_ingress_enabled && var.ingress_subnet_name_new != "") ? 1 : 0
  name                = var.virtual_network_name_new
  resource_group_name = var.ingress_network_rg_name_new
}

data "azurerm_key_vault" "domainsslkv" {
  name                = module.keyvault-cep.kv_name
  resource_group_name = var.rg_name
}
data "azurerm_key_vault_certificate" "domainsslcert" {
  name         = var.cert_name
  key_vault_id = data.azurerm_key_vault.domainsslkv.id
}
# data "azurerm_key_vault_certificate" "domainsslcert" {
#   count               = var.web_ingress_enabled ? 1 : 0
#   name         = var.cert_name
#   key_vault_id = module.keyvault-cep.kv_id
# }

data "azurerm_key_vault_certificate" "domainsslcertcnh" {
  name         = var.cert_name_cnh
  key_vault_id = module.keyvault-cep.kv_id
}


module "gateway_mi" {
  source  = "app.terraform.io/AIZ/managed-identity-user-cep/azurerm"
  version = "3.0.0"

  app_env      = var.app_env
  default_tags = local.default_tags
  tags         = var.tags
  location     = var.location
  mi_name      = lower(format("%s-appgwi", "gears"))
  rg_name      = var.rg_name

}



//--------------------------------------------------------------------
// Modules
module "appgw_cep" {
  source  = "app.terraform.io/AIZ/appgw-cep/azurerm"
  version = "3.0.0"
  # count   = var.app_env == "prod" ? 1 : var.app_env == "model" ? 1 : 0
  count = (var.app_env == "prod") ? 1 : 0


  appgw = {
    name      = format("%s-%s", var.app_name, var.app_env)
    subnet_id = var.webingress_subnet_id
    // Get Webingress ip , worst case pick an ip from the range 
    private_ip   = cidrhost(data.azurerm_subnet.web_ingress_subnet[0].address_prefixes[0], 4)
    sku_capacity = 2
  }
  autoscale_max_capacity = 4
  autoscale_min_capacity = 1

  backend_address_pools = [
    {
      name         = format("%s-ui-%s", var.app_name, var.app_env)
      ip_addresses = null
      fqdns        = ["app-gears-angular-prod.ase-epggears-prod.appserviceenvironment.net"]
    }
  ]
  backend_http_listeners = local.http_listeners

  backend_http_settings = [
    {
      name                         = "ui-settings"
      pick_host_name_from_backend  = true
      host_name                    = null
      enable_cookie_based_affinity = false
      affinity_cookie_name         = null
      path                         = null
      port                         = 443
      request_timeout              = 400
      probe_settings = {
        match_body          = null
        path                = "/"
        unhealthy_threshold = 3
        timeout             = 5
        interval            = 10
        status_code         = [200]
      }
    }
  ]
  certificates = [
    {
      cert_name           = var.cert_name
      key_vault_secret_id = data.azurerm_key_vault_certificate.domainsslcert.secret_id
    },
    {
      cert_name = var.cert_name_cnh
      #key_vault_secret_id = data.azurerm_key_vault_certificate.domainsslcertcnh.secret_id
      key_vault_secret_id = var.app_env == "prod" ? ("https://kv-gears-prod-d123zxf2.vault.azure.net/secrets/gearsDOTcnhDOTcom-PFX/f624f24eb3bc4c50880c886ecb9dde02") : data.azurerm_key_vault_certificate.domainsslcertcnh.secret_id
    }
  ]
  # diagnostics_retention_days = 30
  enable_autoscale = "true"
  identity_id      = module.gateway_mi.mi_id
  is_public        = "true"
  location         = var.location
  # log_analytics_workspace_id = var.SENTINEL_LA_ID
  rg_name = var.rg_name
  # default_tags               = local.default_tags
  tags = var.default_tags

}


#New Appgateway
module "appgw_cep_new" {
  source  = "app.terraform.io/AIZ/appgw-cep/azurerm"
  version = "3.0.0"
  count   = (var.app_env == "model" || var.app_env == "prod") ? 1 : 0


  appgw = {
    name      = format("%s-%s-new", var.app_name, var.app_env)
    subnet_id = var.webingress_subnet_id_new
    // Get Webingress ip , worst case pick an ip from the range 
    private_ip   = cidrhost(data.azurerm_subnet.web_ingress_subnet_new[0].address_prefixes[0], 4)
    sku_capacity = 2
  }
  autoscale_max_capacity = 4
  autoscale_min_capacity = 1

  backend_address_pools = [
    {
      name         = format("%s-ui-%s", var.app_name, var.app_env)
      ip_addresses = null
      fqdns        = ["app-gears-angular-model.ase-epggears-model.appserviceenvironment.net"]
    }
  ]
  backend_http_listeners = local.http_listeners

  backend_http_settings = [
    {
      name                         = "ui-settings"
      pick_host_name_from_backend  = true
      host_name                    = null
      enable_cookie_based_affinity = false
      affinity_cookie_name         = null
      path                         = null
      port                         = 443
      request_timeout              = 400
      probe_settings = {
        match_body          = null
        path                = "/"
        unhealthy_threshold = 3
        timeout             = 5
        interval            = 10
        status_code         = [200]
      }
    }
  ]
  certificates = [
    {
      cert_name           = var.cert_name
      key_vault_secret_id = data.azurerm_key_vault_certificate.domainsslcert.secret_id
    },
    {
      cert_name = var.cert_name_cnh
      #key_vault_secret_id = data.azurerm_key_vault_certificate.domainsslcertcnh.secret_id
      key_vault_secret_id = var.app_env == "prod" ? ("https://kv-gears-prod-d123zxf2.vault.azure.net/secrets/gearsDOTcnhDOTcom-PFX/f624f24eb3bc4c50880c886ecb9dde02") : data.azurerm_key_vault_certificate.domainsslcertcnh.secret_id
    }
  ]
  # diagnostics_retention_days = 30
  enable_autoscale = "true"
  identity_id      = module.gateway_mi.mi_id
  is_public        = "true"
  location         = var.location
  # log_analytics_workspace_id = var.SENTINEL_LA_ID
  rg_name = var.rg_name
  # default_tags               = local.default_tags
  tags = var.default_tags

}
