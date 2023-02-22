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

resource "azurerm_virtual_network_peering" "spoke_2_vnet_to_hub" {
  name                         = "peer-${var.spoke_2_vnet}-to-hub"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.spoke_2_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.hub_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = true
}

resource "azurerm_virtual_network_peering" "hub_to_spoke_2_vnet" {
  name                         = "peer-hub-to-${var.spoke_2_vnet}"
  resource_group_name          = azurerm_resource_group.rg.name
  virtual_network_name         = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.spoke_2_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

resource "azurerm_route_table" "spoke_1_vms_rt" {
  name                          = "spoke-1-vms-rt"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  disable_bgp_route_propagation = false

  route {
    name                   = "AllGoesThroughNVA"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_network_interface.hub_nva_vm.private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "spoke_1_vms_rt" {
  subnet_id      = azurerm_subnet.spoke_1_test_subnet.id
  route_table_id = azurerm_route_table.spoke_1_vms_rt.id
}

resource "azurerm_route_table" "spoke_2_vms_rt" {
  name                          = "spoke-2-vms-rt"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  disable_bgp_route_propagation = false

  route {
    name                   = "AllGoesThroughNVA"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_network_interface.hub_nva_vm.private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "spoke_2_vms_rt" {
  subnet_id      = azurerm_subnet.spoke_2_test_subnet.id
  route_table_id = azurerm_route_table.spoke_2_vms_rt.id
}