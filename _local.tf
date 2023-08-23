locals {
  subnet_id = length(data.azurerm_subnet.subnet) > 0 ? data.azurerm_subnet.subnet[0].id : null
}
