resource "azurerm_resource_group" "rg" {
  name     = var.rg
  location = var.main_region
}