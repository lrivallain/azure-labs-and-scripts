resource "azurerm_public_ip" "vpn_gateway_pip" {
  name                = "vpn-gateway-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "vpn_gateway_pip2" {
  name                = "vpn-gateway-pip2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "vpn_gateway_pip3" {
  name                = "vpn-gateway-pip3"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}


resource "azurerm_virtual_network_gateway" "vpn_gateway" {
  name                = "vpn-gateway"
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
    public_ip_address_id          = azurerm_public_ip.vpn_gateway_pip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.avs_lz_gw_subnet.id
  }

  ip_configuration {
    name                          = "secondary"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway_pip2.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.avs_lz_gw_subnet.id
  }

  ip_configuration {
    name                          = "tertiary"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway_pip3.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.avs_lz_gw_subnet.id
  }

  vpn_client_configuration {
    address_space = [
      var.vpn_client_prefix
    ]
    vpn_client_protocols = [
      "IkeV2",
      "OpenVPN"
    ]
    vpn_auth_types = [
      "Certificate"
    ]
    root_certificate {
      name = "P2SRootCert"
      public_cert_data = file("/home/lrivallain/wd/az-lab/Terraform/data/vpn-certs/P2S_RootCert_for_import.crt")
    }
  }
}