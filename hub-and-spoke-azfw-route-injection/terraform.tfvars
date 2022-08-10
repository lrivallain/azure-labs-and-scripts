# ------------------------------------------------------------------------------
# Region to deploy the lab and associated components
main_region       = "westeurope"
subscription_name = "to-be-changed"
subscription_id   = "to-be-changed"

# ------------------------------------------------------------------------------
# Resource Group
rg = "hsazfw-RG"

# ------------------------------------------------------------------------------
# HUB
hub_vnet               = "hub-vnet"
hub_prefix             = "10.1.0.0/16"
hub_gw_subnet          = "GatewaySubnet"
hub_gw_subnet_prefix   = "10.1.0.0/24"
hub_rs_subnet          = "RouteServerSubnet"
hub_rs_subnet_prefix   = "10.1.1.0/24"
hub_azfw_subnet        = "AzureFirewallSubnet"
hub_azfw_subnet_prefix = "10.1.2.0/24"
hub_ri_subnet          = "RouteInjectionSubnet"
hub_ri_subnet_prefix   = "10.1.3.0/24"

# ------------------------------------------------------------------------------
# Spokes
spoke_1_vnet               = "spoke-1-vnet"
spoke_1_prefix             = "10.2.0.0/16"
spoke_1_test_subnet        = "TestSubnet"
spoke_1_test_subnet_prefix = "10.2.0.0/24"

spoke_2_vnet               = "spoke-2-vnet"
spoke_2_prefix             = "10.3.0.0/16"
spoke_2_test_subnet        = "TestSubnet"
spoke_2_test_subnet_prefix = "10.3.0.0/24"

# ------------------------------------------------------------------------------
# Route injection
route_to_announce = "0.0.0.0/0"

# ------------------------------------------------------------------------------
# Bypass Azure Firewall route to VM when incoming from this specific IP
# (testing purposes only): set it according to your current public IP address.
# my_ip = "1.1.1.1"