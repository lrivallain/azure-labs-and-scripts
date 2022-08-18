resource "azurerm_virtual_network" "appgw-vnet" {
  name                = "appgw-vnet"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.1.0.0/16"]
}

resource "azurerm_subnet" "frontend" {
  name                 = "appgw-frontend"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.appgw-vnet.name
  address_prefixes     = ["10.1.0.0/24"]
}

resource "azurerm_subnet" "backend" {
  name                 = "appgw-backend"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.appgw-vnet.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_network_security_group" "backend_nsg" {
  name                = "backend-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  security_rule = [
    {
      name                                       = "HTTP"
      description                                = "Allow HTTP"
      protocol                                   = "Tcp"
      source_port_range                          = "*"
      destination_port_range                     = "80"
      source_address_prefix                      = "10.1.0.0/16"
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

resource "azurerm_subnet_network_security_group_association" "backend_nsg" {
  subnet_id                 = azurerm_subnet.backend.id
  network_security_group_id = azurerm_network_security_group.backend_nsg.id
}