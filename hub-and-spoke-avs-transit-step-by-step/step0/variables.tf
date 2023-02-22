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
variable "hub_vms_subnet" { type = string }
variable "hub_vms_subnet_prefix" { type = string }
variable "hub_nva_subnet_gw" { type = string }
variable "hub_vpn_aad_tenant_id" { type = string }
variable "hub_vpn_client_prefix" { type = string }

# ------------------------------------------------------------------------------
# Spokes
variable "spoke_1_vnet" { type = string }
variable "spoke_1_prefix" { type = string }
variable "spoke_1_test_subnet" { type = string }
variable "spoke_1_test_subnet_prefix" { type = string }

variable "spoke_2_vnet" { type = string }
variable "spoke_2_prefix" { type = string }
variable "spoke_2_test_subnet" { type = string }
variable "spoke_2_test_subnet_prefix" { type = string }

# ------------------------------------------------------------------------------
# AVS Transit
variable "avs_transit_vnet" { type = string }
variable "avs_transit_prefix" { type = string }
variable "avs_transit_gw_subnet" { type = string }
variable "avs_transit_gw_subnet_prefix" { type = string }
variable "avs_transit_rs_subnet" { type = string }
variable "avs_transit_rs_subnet_prefix" { type = string }
variable "avs_transit_bgp_subnet" { type = string }
variable "avs_transit_bgp_subnet_prefix" { type = string }
variable "avs_transit_nva_subnet_gw" { type = string }
variable "avs_er_circuit_id" { type = string }
variable "avs_er_auth_key" { type = string }

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
# Route injection HUB
variable "hub_route_server_ip1" { type = string }
variable "hub_route_server_ip2" { type = string }
variable "hub_route_server_asn" {
  type    = string
  default = "65515"
}


variable "hub_nva_vm_asn" {
  type    = string
  default = "65001"
}

variable "hub_route_to_announce" {
  type    = string
  default = "0.0.0.0/0"
}

# ------------------------------------------------------------------------------
# Route injection AVS transit
variable "avs_transit_route_server_ip1" { type = string }
variable "avs_transit_route_server_ip2" { type = string }
variable "avs_transit_route_server_asn" {
  type    = string
  default = "65515"
}


variable "avs_transit_bgp_vm_asn" {
  type    = string
  default = "65002"
}

variable "avs_transit_route_to_announce" {
  type    = string
  default = "0.0.0.0/0"
}

variable "avs_mgnt_route_to_announce" {
  type = string
}

variable "avs_wkld_route_to_announce" {
  type = string
}

# ------------------------------------------------------------------------------
# Bypass
variable "my_ip" { type = string }