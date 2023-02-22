resource "azurerm_public_ip" "hub_rs_pip" {
  name                = "hub-rs-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_route_server" "hub_route_server" {
  name                             = "HubRouterServer"
  resource_group_name              = azurerm_resource_group.rg.name
  location                         = azurerm_resource_group.rg.location
  sku                              = "Standard"
  public_ip_address_id             = azurerm_public_ip.hub_rs_pip.id
  subnet_id                        = azurerm_subnet.hub_rs_subnet.id
  branch_to_branch_traffic_enabled = true

  lifecycle {
    ignore_changes = [
      # Ignore changes to the route server's public IP address
      subnet_id,
    ]
  }
}