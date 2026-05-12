module "api_manager_api" {
  source  = "app.terraform.io/AIZ/api-cep/azurerm"
  version = "3.0.0"

  providers = {
    azurerm = azurerm.azurerm_gh_shared
  }
  rg_name             = var.api_vars.rg_name
  api_management_name = var.api_vars.api_management_name

  api_logger = {
    resource_id         = null
    buffered            = true
    description         = "for logging"
    enable_app_insights = false

    instrumention_key = var.apim_appinsights_id
  }

  apis = [
    {
      name                = "auto-gears_vendor"
      display_name        = "auto-gears-vendorapi-${title(var.app_env)}"
      description         = "Auto gears_vendor API"
      path                = "autogears/${var.app_env}"
      protocols           = ["https"]
      product_ids         = [module.product_gears.product_ids["auto-gears-${var.app_env}"]]
      version_scheme      = "Segment"
      version_header_name = null
      version_query_name  = null

      versions = [
        {
          version               = "v1"
          revision              = 1
          service_url           = var.gears_vendor_api_url
          subscription_required = true
          soap_pass_through     = false
          operations            = null
          diagnostics = {
            sampling_percentage            = "100.0"
            always_log_errors              = true
            log_client_ip                  = true
            verbosity                      = "information"
            http_correlation_protocol      = "Legacy"
            enable_frontend_request_config = true
            frontend_request_config = {
              body_bytes = 5000
              headers_to_log = [
                "content-type",
                "accept",
                "origin",
                "CorrelationId",
              ]
            }
            enable_frontend_response_config = true
            frontend_response_config = {
              body_bytes = 5000
              headers_to_log = [
                "CorrelationId",
              ]
            }
            backend_request_config  = null
            backend_response_config = null
          }
          import_content = {
            content_format                      = "openapi+json"
            content_value                       = (var.app_env == "dev") ? file("${path.module}/dev/swagger.json") : (var.app_env == "qa") ? file("${path.module}/qa/swagger.json") : (var.app_env == "model") ? file("${path.module}/model/swagger.json") : file("${path.module}/prod/swagger.json")
            wsdl_selector_service_name          = null
            wsdl_selector_endpoint_name         = null
            diagnostic_logs                     = true
            application_insight_diagnostic_logs = true
          }
          policy = <<XML
            <policies>
                <inbound>
                  <cors>
                    <allowed-origins>
                        <origin>*</origin>
                    </allowed-origins>
                    <allowed-methods>
                        <method>*</method>
                    </allowed-methods>
                    <allowed-headers>
                        <header>*</header>
                    </allowed-headers>
                    <expose-headers>
                        <header>*</header>
                    </expose-headers>
                  </cors>
                </inbound>
                <outbound>
                    <base />
                </outbound>
                <on-error>
                    <base />
                </on-error>
            </policies>
            XML
        }
      ]
    }
  ]
}
module "Sitefinity_SF_api" {
  source  = "app.terraform.io/AIZ/api-cep/azurerm"
  version = "3.0.0"

  providers = {
    azurerm = azurerm.azurerm_gh_shared
  }
  rg_name             = var.api_vars.rg_name
  api_management_name = var.api_vars.api_management_name

  api_logger = {
    resource_id         = null
    buffered            = true
    description         = "for logging"
    enable_app_insights = false

    instrumention_key = var.apim_appinsights_id
  }

  apis = [
    {
      name                = "auto-gears-Sitefinity-SF-api"
      display_name        = "auto-gears-Sitefinity-SF-api-${title(var.app_env)}"
      description         = "auto-gearsSitefinity_SF_api API"
      path                = "autogears/${var.app_env}/Sitefinity"
      protocols           = ["https"]
      product_ids         = [module.product_gears.product_ids["auto-gears-${var.app_env}"]]
      version_scheme      = "Segment"
      version_header_name = null
      version_query_name  = null

      versions = [
        {
          version               = "v1"
          revision              = 1
          service_url           = var.sitefinity_api_url
          subscription_required = true
          soap_pass_through     = false
          operations            = null
          diagnostics = {
            sampling_percentage            = "100.0"
            always_log_errors              = true
            log_client_ip                  = true
            verbosity                      = "information"
            http_correlation_protocol      = "Legacy"
            enable_frontend_request_config = true
            frontend_request_config = {
              body_bytes = 5000
              headers_to_log = [
                "content-type",
                "accept",
                "origin",
                "CorrelationId",
              ]
            }
            enable_frontend_response_config = true
            frontend_response_config = {
              body_bytes = 5000
              headers_to_log = [
                "CorrelationId",
              ]
            }
            backend_request_config  = null
            backend_response_config = null
          }
          import_content = {
            content_format                      = "openapi+json"
            content_value                       = (var.app_env == "dev") ? file("${path.module}/dev/swagger-sf.json") : (var.app_env == "qa") ? file("${path.module}/qa/swagger-sf.json") : (var.app_env == "model") ? file("${path.module}/model/swagger-sf.json") : file("${path.module}/prod/swagger-sf.json")
            wsdl_selector_service_name          = null
            wsdl_selector_endpoint_name         = null
            diagnostic_logs                     = true
            application_insight_diagnostic_logs = true
          }
          policy = <<XML
            <policies>
                <inbound>
                  <cors>
                    <allowed-origins>
                        <origin>*</origin>
                    </allowed-origins>
                    <allowed-methods>
                        <method>*</method>
                    </allowed-methods>
                    <allowed-headers>
                        <header>*</header>
                    </allowed-headers>
                    <expose-headers>
                        <header>*</header>
                    </expose-headers>
                  </cors>
                </inbound>
                <outbound>
                    <base />
                </outbound>
                <on-error>
                    <base />
                </on-error>
            </policies>
            XML
        }
      ]
    }
  ]
}
# # Products

module "product_gears" {
  source  = "app.terraform.io/AIZ/api-product-cep/azurerm"
  version = "3.0.0"

  providers = {
    azurerm = azurerm.azurerm_gh_shared
  }
  #depends_on = [module.namedvalues[0].module.apim-named-values-oktaurl]
  rg_name             = var.api_vars.rg_name
  api_management_name = var.api_vars.api_management_name

  products = [
    {
      display_name          = "auto-gears-${var.app_env}"
      description           = "Subscribers will have access to the gears APIs."
      subscription_required = true
      approval_required     = false
      published             = true
      aad_group             = null
      okta_groups           = []
      policy                = <<XML
        <policies>
          <inbound>
              <base />
          </inbound>
          <backend>
              <base />
          </backend>
          <outbound>
              <base />
          </outbound>
          <on-error>
              <base />
          </on-error>
      </policies>
      XML
    }
  ]
}
module "apim-subscription-gears" {
  source  = "app.terraform.io/AIZ/apim-subscription-cep/azurerm"
  version = "3.0.0"

  providers = {
    azurerm = azurerm.azurerm_gh_shared
  }


  rg_name             = var.api_vars.rg_name
  api_management_name = var.api_vars.api_management_name
  subscriptions = [
    {
      display_name        = "auto-gears-${var.app_env}"
      product_resource_id = module.product_gears.product_resource_ids["auto-gears-${var.app_env}"]
      state               = "active"
      primary_key         = null
      secondary_key       = null
      allow_tracing       = true
  }]
}

provider "azurerm" {
  features {}

  alias                      = "azurerm_gh_shared"
  subscription_id            = var.gh_shared_subscription
  skip_provider_registration = "true"
}
