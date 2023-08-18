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
# AVS Transit
variable "avs_lz_vnet" { type = string }
variable "avs_lz_prefix" { type = string }
variable "avs_lz_gw_subnet" { type = string }
variable "avs_lz_gw_subnet_prefix" { type = string }
variable "avs_lz_rs_subnet" { type = string }
variable "avs_lz_rs_subnet_prefix" { type = string }
variable "avs_lz_bgp_subnet" { type = string }
variable "avs_lz_bgp_subnet_prefix" { type = string }
variable "avs_lz_nva_subnet_gw" { type = string }
variable "avs_er_circuit_id" { type = string }
variable "avs_er_auth_key" { type = string }

# ------------------------------------------------------------------------------
# VPN
variable "vpn_aad_tenant_id" { type = string }
variable "vpn_client_prefix" { type = string }

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
  default = "Standard_B1ls"
}
variable "vm_admin_username" {
  type    = string
  default = "azureuser"
}
variable "vm_admin_password" { type = string }
variable "vm_ubuntu_password" { type = string } # Temp: see https://github.com/hashicorp/terraform-provider-azurerm/issues/18069

# ------------------------------------------------------------------------------
# Route injection AVS transit
variable "avs_lz_route_server_ip1" { type = string }
variable "avs_lz_route_server_ip2" { type = string }
variable "avs_lz_route_server_asn" {
  type    = string
  default = "65515"
}


variable "avs_lz_bgp_vm_asn" {
  type    = string
  default = "65002"
}

variable "avs_lz_route_to_announce" {
  type    = string
  default = "0.0.0.0/0"
}

# ------------------------------------------------------------------------------
# Bypass
variable "my_ip" { type = string }