resource "azurerm_virtual_network" "avs_transit_vnet" {
  name = var.avs_transit_vnet
  address_space = [
    var.avs_transit_prefix
  ]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "avs_transit_gw_subnet" {
  name                 = var.avs_transit_gw_subnet
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.avs_transit_vnet.name
  address_prefixes = [
    var.avs_transit_gw_subnet_prefix
  ]
}

resource "azurerm_public_ip" "avs_er_gateway_pip" {
  name                = "avs-er-gateway-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_virtual_network_gateway" "avs_er_gateway" {
  name                = "avs-er-gateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  type                = "ExpressRoute"
  sku                 = "ErGw1AZ"
  enable_bgp          = true
  active_active       = false

  ip_configuration {
    name                          = "default"
    public_ip_address_id          = azurerm_public_ip.avs_er_gateway_pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.avs_transit_gw_subnet.id
  }
}

# ExpressRoute to AVS deployment
resource "azurerm_virtual_network_gateway_connection" "avs" {
  name                       = "avs-er-gateway-connection"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  type                       = "ExpressRoute"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.avs_er_gateway.id
  express_route_circuit_id   = var.avs_er_circuit_id
  authorization_key          = var.avs_er_auth_key
}

resource "azurerm_virtual_network_peering" "avs_transit_to_hub" {
  name                         = "peer-${var.avs_transit_vnet}-to-hub"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.avs_transit_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.hub_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "hub_to_avs_transit" {
  name                         = "peer-hub-to-${var.avs_transit_vnet}"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.avs_transit_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}