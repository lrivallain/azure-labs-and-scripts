resource "azurerm_virtual_network" "spoke_1_vnet" {
  name = var.spoke_1_vnet
  address_space = [
    var.spoke_1_prefix
  ]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "spoke_1_test_subnet" {
  name                 = var.spoke_1_test_subnet
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.spoke_1_vnet.name
  address_prefixes = [
    var.spoke_1_test_subnet_prefix
  ]
}

resource "azurerm_virtual_network" "spoke_2_vnet" {
  name = var.spoke_2_vnet
  address_space = [
    var.spoke_2_prefix
  ]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "spoke_2_test_subnet" {
  name                 = var.spoke_2_test_subnet
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.spoke_2_vnet.name
  address_prefixes = [
    var.spoke_2_test_subnet_prefix
  ]
}