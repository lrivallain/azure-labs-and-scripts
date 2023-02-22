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

resource "azurerm_subnet" "hub_nva_subnet" {
  name                 = var.hub_nva_subnet
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes = [
    var.hub_nva_subnet_prefix
  ]
}

resource "azurerm_network_security_group" "hub_nva_subnet_nsg" {
  name                = "hub-nva-subnet-nsg"
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
    }
  ]
}

resource "azurerm_subnet_network_security_group_association" "hub_nva_subnet_nsg" {
  subnet_id                 = azurerm_subnet.hub_nva_subnet.id
  network_security_group_id = azurerm_network_security_group.hub_nva_subnet_nsg.id
}

resource "azurerm_public_ip" "hub_vpn_gateway_pip" {
  name                = "hub-vpn-gateway-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "hub_vpn_gateway_pip2" {
  name                = "hub-vpn-gateway-pip2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "hub_vpn_gateway_pip3" {
  name                = "hub-vpn-gateway-pip3"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_virtual_network_gateway" "hub_vpn_gateway" {
  name                = "hub-vpn-gateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  type                = "Vpn"
  vpn_type            = "RouteBased"
  generation          = "Generation2"
  sku                 = "VpnGw2"
  enable_bgp          = false
  active_active       = true

  ip_configuration {
    name                          = "default"
    public_ip_address_id          = azurerm_public_ip.hub_vpn_gateway_pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.hub_gw_subnet.id
  }

  ip_configuration {
    name                          = "secondary"
    public_ip_address_id          = azurerm_public_ip.hub_vpn_gateway_pip2.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.hub_gw_subnet.id
  }

  ip_configuration {
    name                          = "tertiary"
    public_ip_address_id          = azurerm_public_ip.hub_vpn_gateway_pip3.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.hub_gw_subnet.id
  }

  vpn_client_configuration {
    address_space = [
      var.hub_vpn_client_prefix
    ]
    vpn_client_protocols = [
      "OpenVPN"
    ]
    vpn_auth_types = [
      "AAD"
    ]
    aad_tenant   = "https://login.microsoftonline.com/${var.hub_vpn_aad_tenant_id}/"
    aad_audience = "41b23e61-6c1e-4545-b367-cd054e0ed4b4" # Azure Public
    aad_issuer   = "https://sts.windows.net/${var.hub_vpn_aad_tenant_id}/"
  }
}