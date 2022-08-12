#-----------------------------------------------------------------
# DO NOT CHANGE
# Update any variables from the terraform.tfvars file as required
#-----------------------------------------------------------------

# Region to deploy the lab and associated components
variable "main_region" { type = string }
variable "subscription_name" { type = string }
variable "subscription_id" { type = string }

# ------------------------------------------------------------------------------
# Resource Group
variable "rg" { type = string }

# ------------------------------------------------------------------------------
# Azure global
variable "azure_global_prefix" {
  type    = string
  default = "10.0.0.0/8"
}

# ------------------------------------------------------------------------------
# HUB
variable "hub_vnet" { type = string }
variable "hub_prefix" { type = string }
variable "hub_gw_subnet" { type = string }
variable "hub_gw_subnet_prefix" { type = string }
variable "hub_rs_subnet" { type = string }
variable "hub_rs_subnet_prefix" { type = string }
variable "hub_nva_subnet" { type = string }
variable "hub_nva_subnet_prefix" { type = string }
variable "hub_nva_subnet_gw" { type = string }

# ------------------------------------------------------------------------------
# Spokes
variable "spoke_1_vnet" { type = string }
variable "spoke_1_prefix" { type = string }
variable "spoke_1_test_subnet" { type = string }
variable "spoke_1_test_subnet_prefix" { type = string }

# ------------------------------------------------------------------------------
# Test VMs
variable "vm_publisher" {
  type    = string
  default = "Canonical"
}
variable "vm_offer" {
  type    = string
  default = "0001-com-ubuntu-server-jammy"
}
variable "vm_sku" {
  type    = string
  default = "22_04-lts-gen2"
}
variable "vm_version" {
  type    = string
  default = "latest"
}
variable "vm_storage_account_type" {
  type    = string
  default = "Standard_LRS"
}
variable "vm_size" {
  type    = string
  default = "Standard_B1s"
}
variable "vm_admin_username" {
  type    = string
  default = "azureuser"
}

# # ------------------------------------------------------------------------------
# # Route injection
variable "nva_asn" {
  type    = string
  default = "65001"
}
variable "route_to_announce" {
  type    = string
  default = "0.0.0.0/0"
}

# ------------------------------------------------------------------------------
# Bypass
variable "my_ip" { type = string }