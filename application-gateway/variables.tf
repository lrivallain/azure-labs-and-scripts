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
# App Gateway
variable "backend_address_pool_name" {
  default = "backend-address-pool"
}

variable "frontend_port_name" {
  default = "FrontHTTP"
}

variable "frontend_ip_configuration_name" {
  default = "frontend-ip-configuration"
}

variable "backend_http_settings_name" {
  default = "http-settings"
}

variable "http_listener_name" {
  default = "http-listener"
}

variable "request_routing_rule_name" {
  default = "request_routing_rule"
}

variable "redirect_configuration_name" {
  default = "myRedirectConfig"
}


# ------------------------------------------------------------------------------
# Web workers VMs
variable "web_workers_count" {
  default = 2
}
variable "failback_workers_count" {
  default = 0
}
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