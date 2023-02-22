# ------------------------------------------------------------------------------
# Region to deploy the lab and associated components
main_region       = "westeurope"
subscription_name = "to-be-changed"
subscription_id   = "to-be-changed"
vm_admin_password = "to-be-changed"
#echo 'to-be-changed' | mkpasswd --method=SHA-512 --rounds=4096 -s
vm_ubuntu_password="$6$rounds=4096$Igar0ay9tD$WOiaTfNaGtt2jS6ZVaDv3RIzeE/Yos7qNhReKMbH3Hpk4d/FC.fAmY2J1swsUK5uAePKgIjmdK5W7RTF/J4Fw1"
azure_global_prefix = "to-be-changed"

# ------------------------------------------------------------------------------
# Resource Group
rg = "nva-testing-RG"

# ------------------------------------------------------------------------------
# HUB
hub_vnet              = "hub-vnet"
hub_prefix            = "10.100.200.0/24"
hub_gw_subnet         = "GatewaySubnet"
hub_gw_subnet_prefix  = "10.100.200.0/27"
hub_rs_subnet         = "RouteServerSubnet"
hub_rs_subnet_prefix  = "10.100.200.32/27"
hub_nva_subnet        = "NVASubnet"
hub_nva_subnet_prefix = "10.100.200.64/28"
hub_vms_subnet        = "VMsSubnet"
hub_vms_subnet_prefix = "10.100.200.80/28"
hub_route_server_ip1  = "10.100.200.37"
hub_route_server_ip2  = "10.100.200.36"
hub_nva_vm_asn        = "65001"
hub_nva_subnet_gw     = "10.100.200.65"
hub_vpn_client_prefix = "10.100.204.0/24"
hub_vpn_aad_tenant_id = "to-be-changed"

# ------------------------------------------------------------------------------
# Route injection
hub_route_to_announce = "0.0.0.0/0"

# ------------------------------------------------------------------------------
# Spokes 1 & 2
spoke_1_vnet               = "spoke-1-vnet"
spoke_1_prefix             = "10.100.201.0/24"
spoke_1_test_subnet        = "VMsSubnet"
spoke_1_test_subnet_prefix = "10.100.201.0/28"

spoke_2_vnet               = "spoke-2-vnet"
spoke_2_prefix             = "10.100.202.0/24"
spoke_2_test_subnet        = "VMsSubnet"
spoke_2_test_subnet_prefix = "10.100.202.0/28"

# # ------------------------------------------------------------------------------
# # AVS Transit
avs_transit_vnet              = "avs-transit-vnet"
avs_transit_prefix            = "10.100.203.0/24"
avs_transit_gw_subnet         = "GatewaySubnet"
avs_transit_gw_subnet_prefix  = "10.100.203.0/27"
avs_transit_rs_subnet         = "RouteServerSubnet"
avs_transit_rs_subnet_prefix  = "10.100.203.32/27"
avs_transit_bgp_subnet        = "BGPSubnet"
avs_transit_bgp_subnet_prefix = "10.100.203.64/28"
avs_transit_route_server_ip1  = "10.100.203.37"
avs_transit_route_server_ip2  = "10.100.203.36"
avs_transit_bgp_vm_asn        = "65002"
avs_transit_nva_subnet_gw     = "10.100.203.33"

# # ------------------------------------------------------------------------------
# # AVS ExpressRoute
avs_er_auth_key = "to-be-changed"
avs_er_circuit_id = "to-be-changed"

# ------------------------------------------------------------------------------
# Route injection
avs_transit_route_to_announce = "0.0.0.0/0"

# # ------------------------------------------------------------------------------
# # Route injection AVS transit
avs_mgnt_route_to_announce = "to-be-changed"
avs_wkld_route_to_announce = "to-be-changed"

# ------------------------------------------------------------------------------
# Bypass Azure Firewall route to VM when incoming from this specific IP
# (testing purposes only): set it according to your current public IP address.
my_ip = "to-be-changed"