provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "aks-test-demo"
  location = "Central India"
}

module "vnet" {
  source              = "git::https://github.com/tothenew/terraform-azure-vnet.git"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = "10.41.0.0/20"

  virtual_network_peering = false

  subnets = {
    "aks_subnet" = {
      address_prefixes           = ["10.41.1.0/24"]
      associate_with_route_table = false
      is_natgateway              = false
      is_nsg                     = true
      service_delegation         = false
    }
  }
}

module "aks_main" {

  source             = "../.."
  resource_group     = azurerm_resource_group.rg.name
  location           = azurerm_resource_group.rg.location
  vnet_subnet_id     = module.vnet.subnet_ids["aks_subnet"]
  service_cidr       = "10.41.16.0/22"
  vnet_address_space = "10.41.0.0/20"
  aks_pod_cidr       = "10.41.22.0/22"

  create_additional_node_pool = false
}
