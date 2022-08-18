resource "azurerm_public_ip" "pip" {
  name                = "appgw-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_application_gateway" "appgw" {
  name                = "AppGateway"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "appgw-ip-configuration"
    subnet_id = azurerm_subnet.frontend.id
  }

  frontend_port {
    name = var.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.pip.id
  }

  backend_address_pool {
    name = var.backend_address_pool_name
  }

  backend_address_pool {
    name = "${var.backend_address_pool_name}-failback"
  }

  backend_http_settings {
    name                  = var.backend_http_settings_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = var.http_listener_name
    frontend_ip_configuration_name = var.frontend_ip_configuration_name
    frontend_port_name             = var.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    priority                  = 1
    name                      = var.request_routing_rule_name
    rule_type                 = "Basic"
    http_listener_name        = var.http_listener_name
    backend_address_pool_name = var.backend_address_pool_name
    # backend_address_pool_name  = "${var.backend_address_pool_name}-failback"
    backend_http_settings_name = var.backend_http_settings_name
  }
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "nic-assoc01" {
  count                   = var.web_workers_count
  network_interface_id    = azurerm_network_interface.nic[count.index].id
  ip_configuration_name   = "nic-ipconfig-${count.index + 1}"
  backend_address_pool_id = tolist(azurerm_application_gateway.appgw.backend_address_pool).0.id
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "nic-failback-assoc01" {
  count                   = var.failback_workers_count
  network_interface_id    = azurerm_network_interface.nic-failback[count.index].id
  ip_configuration_name   = "nic-ipconfig-${count.index + 1}"
  backend_address_pool_id = tolist(azurerm_application_gateway.appgw.backend_address_pool).1.id
}

output "testing_command" {
  value = "curl -s http://${azurerm_public_ip.pip.ip_address}/api | python3 -m json.tool"
}