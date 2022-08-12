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

resource "azurerm_network_security_group" "spoke_1_test_nsg" {
  name                = "${var.spoke_1_vnet}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  security_rule = [
    {
      name                                       = "SSH"
      description                                = "Allow SSH (alt)"
      protocol                                   = "Tcp"
      source_port_range                          = "*"
      destination_port_range                     = "2222"
      source_address_prefix                      = "${var.my_ip}/32"
      destination_address_prefix                 = var.spoke_1_test_subnet_prefix
      access                                     = "Allow"
      priority                                   = 1000
      direction                                  = "Inbound"
      source_port_ranges                         = []
      destination_port_ranges                    = []
      source_address_prefixes                    = []
      destination_address_prefixes               = []
      destination_application_security_group_ids = []
      source_application_security_group_ids      = []
      }, {
      name                                       = "ICMP"
      description                                = "Allow ICMP"
      protocol                                   = "Icmp"
      source_port_range                          = "*"
      destination_port_range                     = "*"
      source_address_prefix                      = var.azure_global_prefix
      destination_address_prefix                 = "*"
      access                                     = "Allow"
      priority                                   = 1001
      direction                                  = "Inbound"
      source_port_ranges                         = []
      destination_port_ranges                    = []
      source_address_prefixes                    = []
      destination_address_prefixes               = []
      destination_application_security_group_ids = []
      source_application_security_group_ids      = []
    }
  ]
}

resource "azurerm_subnet_network_security_group_association" "spoke_1_vnet_nsg" {
  subnet_id                 = azurerm_subnet.spoke_1_test_subnet.id
  network_security_group_id = azurerm_network_security_group.spoke_1_test_nsg.id
}

resource "azurerm_route_table" "spoke_1_vnet_rt" {
  name                          = "${var.spoke_1_vnet}-rt"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  disable_bgp_route_propagation = false

  route {
    name           = "Bypass"
    address_prefix = "${var.my_ip}/32"
    next_hop_type  = "Internet"
  }
}

resource "azurerm_subnet_route_table_association" "spoke_1_vnet_rt" {
  subnet_id      = azurerm_subnet.spoke_1_test_subnet.id
  route_table_id = azurerm_route_table.spoke_1_vnet_rt.id
}


resource "azurerm_virtual_network_peering" "spoke_1_vnet_to_hub" {
  name                         = "peer-${var.spoke_1_vnet}-to-hub"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.spoke_1_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.hub_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true
}

resource "azurerm_virtual_network_peering" "hub_to_spoke_1_vnet" {
  name                         = "peer-hub-to-${var.spoke_1_vnet}"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke_1_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}