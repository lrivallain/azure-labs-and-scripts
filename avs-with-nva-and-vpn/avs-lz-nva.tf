# Route Injection VM
resource "azurerm_public_ip" "nva_vm_pip" {
  name                = "nva-vm-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

output "nva_vm_pip" {
  value = azurerm_public_ip.nva_vm_pip.ip_address
}

resource "azurerm_network_interface" "nva_vm" {
  name                 = "nva-vm"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.avs_lz_bgp_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.nva_vm_pip.id
  }
}

data "template_file" "nva_vm_cloud_init" {
  template = file("./scripts/nva-cloud-init.yaml")
  vars = {
    admin_user        = "ubuntu" # Temp: see https://github.com/hashicorp/terraform-provider-azurerm/issues/18069
    admin_password    = var.vm_ubuntu_password
    ssh_key           = file("~/.ssh/id_rsa.pub")
    local_asn         = var.avs_lz_bgp_vm_asn
    rs_asn            = var.avs_lz_route_server_asn
    rs_ip1            = var.avs_lz_route_server_ip1
    rs_ip2            = var.avs_lz_route_server_ip2
    route_to_announce = var.avs_lz_route_to_announce
    vm_ip             = azurerm_network_interface.nva_vm.private_ip_address
    gw                = var.avs_lz_nva_subnet_gw
  }
}

resource "azurerm_linux_virtual_machine" "nva-vm" {
  name                = "nva-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = var.vm_admin_username
  network_interface_ids = [
    azurerm_network_interface.nva_vm.id,
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

  custom_data = base64encode(data.template_file.nva_vm_cloud_init.rendered)
}

output "avs_bgp_connect" {
  value = "ssh -p2222 ubuntu@${azurerm_public_ip.nva_vm_pip.ip_address}"
}


resource "azurerm_route_server_bgp_connection" "avs_rs_bgp_connection" {
  name            = "avs-rs-bgp-connection"
  route_server_id = azurerm_route_server.avs_lz_route_server.id
  peer_asn        = var.avs_lz_bgp_vm_asn
  peer_ip         = azurerm_network_interface.nva_vm.private_ip_address
}
