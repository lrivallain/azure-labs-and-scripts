resource "azurerm_virtual_network" "avs_lz_vnet" {
  name = var.avs_lz_vnet
  address_space = [
    var.avs_lz_prefix
  ]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "avs_lz_gw_subnet" {
  name                 = var.avs_lz_gw_subnet
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.avs_lz_vnet.name
  address_prefixes = [
    var.avs_lz_gw_subnet_prefix
  ]
}

resource "azurerm_subnet" "avs_lz_rs_subnet" {
  name                 = var.avs_lz_rs_subnet
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.avs_lz_vnet.name
  address_prefixes = [
    var.avs_lz_rs_subnet_prefix
  ]
}

resource "azurerm_subnet" "avs_lz_bgp_subnet" {
  name                 = var.avs_lz_bgp_subnet
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.avs_lz_vnet.name
  address_prefixes = [
    var.avs_lz_bgp_subnet_prefix
  ]
}

resource "azurerm_network_security_group" "avs_lz_nva_subnet_nsg" {
  name                = "avs-lz-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  security_rule = [{
    name                                       = "SSH"
    description                                = "Allow SSH (alt)"
    protocol                                   = "Tcp"
    source_port_range                          = "*"
    destination_port_range                     = "2222"
    source_address_prefix                      = "${var.my_ip}/32"
    destination_address_prefix                 = "*"
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
      name                                       = "Use-NVA-as-GW"
      description                                = "Allow internal traffic to use the NVA as a gateway"
      protocol                                   = "*"
      source_port_range                          = "*"
      destination_port_range                     = "*"
      source_address_prefix                      = var.azure_global_prefix
      destination_address_prefix                 = "*"
      access                                     = "Allow"
      priority                                   = 1002
      direction                                  = "Inbound"
      source_port_ranges                         = []
      destination_port_ranges                    = []
      source_address_prefixes                    = []
      destination_address_prefixes               = []
      destination_application_security_group_ids = []
      source_application_security_group_ids      = []
    }]
}

resource "azurerm_subnet_network_security_group_association" "avs_lz_nva_subnet_nsg" {
  subnet_id                 = azurerm_subnet.avs_lz_bgp_subnet.id
  network_security_group_id = azurerm_network_security_group.avs_lz_nva_subnet_nsg.id
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
    subnet_id                     = azurerm_subnet.avs_lz_gw_subnet.id
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

resource "azurerm_route_table" "nva_rt" {
  name                          = "nva-rt"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  disable_bgp_route_propagation = false # == enable BGP route propagation...

  # Avoid the NVA to loop on itself to reach Internet
  route {
    name                   = "Internet"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "Internet"
  }
}

resource "azurerm_subnet_route_table_association" "nva_rt" {
  subnet_id      = azurerm_subnet.avs_lz_bgp_subnet.id
  route_table_id = azurerm_route_table.nva_rt.id
}