resource "azurerm_resource_group" "rg" {
  name     = var.rg
  location = var.main_region
}

resource "random_password" "password" {
  length  = 16
  special = true
  lower   = true
  upper   = true
  numeric = true
}