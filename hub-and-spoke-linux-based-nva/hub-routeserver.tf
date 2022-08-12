resource "azurerm_public_ip" "rs-pip" {
  name                = "rs-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_route_server" "route-server" {
  name                             = "RouterServer"
  resource_group_name              = azurerm_resource_group.rg.name
  location                         = azurerm_resource_group.rg.location
  sku                              = "Standard"
  public_ip_address_id             = azurerm_public_ip.rs-pip.id
  subnet_id                        = azurerm_subnet.hub_rs_subnet.id
  branch_to_branch_traffic_enabled = true
}