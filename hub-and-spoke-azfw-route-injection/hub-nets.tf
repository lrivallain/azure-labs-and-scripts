resource "azurerm_virtual_network" "hub_vnet" {
  name = var.hub_vnet
  address_space = [
    var.hub_prefix
  ]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "hub_gw_subnet" {
  name                 = var.hub_gw_subnet
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes = [
    var.hub_gw_subnet_prefix
  ]
}

resource "azurerm_subnet" "hub_rs_subnet" {
  name                 = var.hub_rs_subnet
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes = [
    var.hub_rs_subnet_prefix
  ]
}

resource "azurerm_subnet" "hub_azfw_subnet" {
  name                 = var.hub_azfw_subnet
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes = [
    var.hub_azfw_subnet_prefix
  ]
}

resource "azurerm_subnet" "hub_ri_subnet" {
  name                 = var.hub_ri_subnet
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes = [
    var.hub_ri_subnet_prefix
  ]
}

resource "azurerm_network_security_group" "hub_ri_subnet_nsg" {
  name                = "${var.hub_ri_subnet}-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  security_rule = [
    {
      name                                       = "SSH"
      description                                = "Allow SSH"
      protocol                                   = "Tcp"
      source_port_range                          = "*"
      destination_port_range                     = "22"
      source_address_prefix                      = "*"
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
      name                                       = "ICMP"
      description                                = "Allow ICMP"
      protocol                                   = "Icmp"
      source_port_range                          = "*"
      destination_port_range                     = "*"
      source_address_prefix                      = "*"
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
      }, {
      name                                       = "ICMP-out"
      description                                = "Allow ICMP"
      protocol                                   = "Icmp"
      source_port_range                          = "*"
      destination_port_range                     = "*"
      source_address_prefix                      = "*"
      destination_address_prefix                 = "*"
      access                                     = "Allow"
      priority                                   = 1002
      direction                                  = "Outbound"
      source_port_ranges                         = []
      destination_port_ranges                    = []
      source_address_prefixes                    = []
      destination_address_prefixes               = []
      destination_application_security_group_ids = []
      source_application_security_group_ids      = []
    }
  ]
}

resource "azurerm_subnet_network_security_group_association" "hub_ri_subnet_nsg" {
  subnet_id                 = azurerm_subnet.hub_ri_subnet.id
  network_security_group_id = azurerm_network_security_group.hub_ri_subnet_nsg.id
}

resource "azurerm_public_ip" "er_gateway_pip" {
  name                = "er-gateway-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_virtual_network_gateway" "er_gateway" {
  name                = "er-gateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  type                = "ExpressRoute"
  sku                 = "ErGw1AZ"
  enable_bgp          = true
  active_active       = false

  ip_configuration {
    name                          = "default"
    public_ip_address_id          = azurerm_public_ip.er_gateway_pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.hub_gw_subnet.id
  }

  # bgp_settings {
  #   asn = 64512

  #   peering_addresses {
  #     ip_configuration_name = "default"
  #     apipa_addresses       = ["169.254.21.2"]
  #   }
  # }
}