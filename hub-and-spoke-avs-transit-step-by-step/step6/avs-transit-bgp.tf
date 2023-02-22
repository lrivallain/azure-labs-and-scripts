# Route Injection VM
resource "azurerm_public_ip" "avs_bgp_vm_pip" {
  name                = "avs-bgp-vm-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

output "avs_bgp_vm_pip" {
  value = azurerm_public_ip.avs_bgp_vm_pip.ip_address
}

resource "azurerm_network_interface" "avs_bgp_vm" {
  name                 = "avs-bgp-nic"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.avs_transit_bgp_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.avs_bgp_vm_pip.id
  }
}

data "template_file" "avs_bgp_vm_cloud_init" {
  template = file("./scripts/avs-transit-bgp-cloud-init.yaml")
  vars = {
    admin_user        = "ubuntu" # Temp: see https://github.com/hashicorp/terraform-provider-azurerm/issues/18069
    admin_password    = var.vm_ubuntu_password
    ssh_key           = file("~/.ssh/id_rsa.pub")
    local_asn         = var.avs_transit_bgp_vm_asn
    rs_asn            = var.avs_transit_route_server_asn
    rs_ip1            = var.avs_transit_route_server_ip1
    rs_ip2            = var.avs_transit_route_server_ip2
    route_to_announce = var.avs_transit_route_to_announce
    vm_ip             = azurerm_network_interface.avs_bgp_vm.private_ip_address
    gw                = var.avs_transit_nva_subnet_gw
  }
}

resource "azurerm_linux_virtual_machine" "avs_bgp_vm" {
  name                = "avs-bgp-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = var.vm_admin_username
  network_interface_ids = [
    azurerm_network_interface.avs_bgp_vm.id,
  ]

  admin_ssh_key {
    username   = var.vm_admin_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.vm_storage_account_type
  }

  source_image_reference {
    publisher = var.vm_publisher
    offer     = var.vm_offer
    sku       = var.vm_sku
    version   = var.vm_version
  }

  boot_diagnostics {}

  custom_data = base64encode(data.template_file.avs_bgp_vm_cloud_init.rendered)
}

output "avs_bgp_connect" {
  value = "ssh -p2222 ubuntu@${azurerm_public_ip.avs_bgp_vm_pip.ip_address}"
}

resource "azurerm_route_server_bgp_connection" "avs_rs_bgp_connection" {
  name            = "avs-rs-bgp-connection"
  route_server_id = azurerm_route_server.avs_transit_route_server.id
  peer_asn        = var.avs_transit_bgp_vm_asn
  peer_ip         = azurerm_network_interface.avs_bgp_vm.private_ip_address
}

resource "azurerm_route_table" "avs_nva_rt" {
  name                          = "avs-nva-rt"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  disable_bgp_route_propagation = false

  route {
    name           = "Bypass"
    address_prefix = "${var.my_ip}/32"
    next_hop_type  = "Internet"
  }

  route {
    name                   = "AllGoesThroughNVA"
    address_prefix         = "0.0.0.0/0"
    next_hop_type          = "Internet"
  }
}

resource "azurerm_subnet_route_table_association" "avs-nva-rt" {
  subnet_id      = azurerm_subnet.avs_transit_bgp_subnet.id
  route_table_id = azurerm_route_table.avs_nva_rt.id
}