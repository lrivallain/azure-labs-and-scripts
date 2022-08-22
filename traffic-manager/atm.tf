resource "azurerm_public_ip" "pip" {
  name                = "tm-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "traffic-manager-demo"
}

resource "azurerm_traffic_manager_profile" "atm" {
  name                   = "atm-profile"
  resource_group_name    = azurerm_resource_group.rg.name
  traffic_routing_method = "Priority"

  dns_config {
    relative_name = "traffic-manager-demo-profile"
    ttl           = 10
  }

  monitor_config {
    protocol                     = "HTTP"
    port                         = 80
    path                         = "/api"
    interval_in_seconds          = 10
    timeout_in_seconds           = 5
    tolerated_number_of_failures = 3
  }
}

resource "azurerm_traffic_manager_azure_endpoint" "atm-endpoint" {
  count              = var.web_workers_count
  name               = "web-${count.index + 1}"
  profile_id         = azurerm_traffic_manager_profile.atm.id
  weight             = 100
  priority           = count.index + 1
  target_resource_id = azurerm_public_ip.web-pip[count.index].id
}

output "testing_command" {
  value = "curl -s http://${azurerm_traffic_manager_profile.atm.fqdn}/api | python3 -m json.tool"
}