│ Error: Virtual Network (Subscription: "3f9c2b44-d175-4223-a022-b3052b1335b2"
│ Resource Group Name: "RGSPOKE-CENTRALUS-GA-PCI-WEB-INGRESS-MODEL"
│ Virtual Network Name: "vnet-centralus-ga-pci-web-ingress-model") was not found
│
│   with module.primary.data.azurerm_virtual_network.web_ingress_vnet[0],
│   on modules/primary/appgateway.tf line 9, in data "azurerm_virtual_network" "web_ingress_vnet":
│    9: data "azurerm_virtual_network" "web_ingress_vnet" {
│
╵
Operation failed: failed running terraform plan (exit 1)
