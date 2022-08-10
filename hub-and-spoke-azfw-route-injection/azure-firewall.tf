resource "azurerm_public_ip" "azfw" {
  name                = "azfw-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall_policy" "azfw" {
  name                = "azfw-policy"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
}

resource "azurerm_firewall" "azfw" {
  name                = "azfw"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.azfw.id

  ip_configuration {
    name                 = "azfw-ipconfig"
    subnet_id            = azurerm_subnet.hub_azfw_subnet.id
    public_ip_address_id = azurerm_public_ip.azfw.id
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "azfw_rcg" {
  name               = "azfw-fwpolicy-rcg"
  firewall_policy_id = azurerm_firewall_policy.azfw.id
  priority           = 300

  network_rule_collection {
    name     = "allowany"
    priority = 301
    action   = "Allow"
    rule {
      name                  = "allowany"
      protocols             = ["Any"]
      source_addresses      = ["10.0.0.0/8"]
      destination_addresses = ["*"]
      destination_ports     = ["*"]
    }
  }

  application_rule_collection {
    name     = "allow-internet"
    priority = 302
    action   = "Allow"
    rule {
      name = "Allow-Google"
      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
      source_addresses = [
        "10.2.0.0/16",
        "10.3.0.0/16",
      ]
      destination_fqdns = [
        "*.google.com",
        "google.com"
      ]
    }
  }
}


resource "azurerm_log_analytics_workspace" "azfw-law" {
  name                = "azfw-law"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}