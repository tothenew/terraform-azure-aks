data "azurerm_subnet" "subnet" {
  count                = var.subnet_network_name == "" ? 1 : 0
  name                 = "subnet-k8s"
  virtual_network_name = var.virtual_network_name == "" ? azurerm_virtual_network.vnet[0].name : var.virtual_network_name
  resource_group_name  = azurerm_resource_group.rg.name
}