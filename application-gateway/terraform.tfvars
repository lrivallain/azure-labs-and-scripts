# ------------------------------------------------------------------------------
# Region to deploy the lab and associated components
main_region       = "westeurope"
subscription_name = "to-be-changed"
subscription_id   = "to-be-changed"

# ------------------------------------------------------------------------------
# Resource Group
rg = "appgw-test-RG"

# ------------------------------------------------------------------------------
# Web workers VMs
web_workers_count      = 2
failback_workers_count = 2