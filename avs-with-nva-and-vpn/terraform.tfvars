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
rg = "vpn-testing-RG"

# ------------------------------------------------------------------------------
# AVS Transit
avs_lz_vnet              = "avs-lz-vnet"
avs_lz_prefix            = "10.100.203.0/24"
avs_lz_gw_subnet         = "GatewaySubnet"
avs_lz_gw_subnet_prefix  = "10.100.203.0/27"
avs_lz_rs_subnet         = "RouteServerSubnet"
avs_lz_rs_subnet_prefix  = "10.100.203.32/27"
avs_lz_bgp_subnet        = "NVASubnet"
avs_lz_bgp_subnet_prefix = "10.100.203.64/28"
avs_lz_route_server_ip1  = "10.100.203.37"
avs_lz_route_server_ip2  = "10.100.203.36"
avs_lz_bgp_vm_asn        = "65002"
avs_lz_nva_subnet_gw     = "10.100.203.33"

# ------------------------------------------------------------------------------
# VPN
vpn_aad_tenant_id = "to-be-changed"
vpn_client_prefix = "10.100.204.0/24"

# ------------------------------------------------------------------------------
# AVS ExpressRoute
avs_er_auth_key = "to-be-changed"
avs_er_circuit_id = "to-be-changed"

# ------------------------------------------------------------------------------
# Route injection
avs_lz_route_to_announce = "0.0.0.0/0"

# ------------------------------------------------------------------------------
# Bypass Azure Firewall route to VM when incoming from this specific IP
# (testing purposes only): set it according to your current public IP address.
my_ip = "to-be-changed"