# Route Injection VM
resource "azurerm_public_ip" "nva-pip" {
  name                = "nva-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

output "nva-pip" {
  value = azurerm_public_ip.nva-pip.ip_address
}

resource "azurerm_network_interface" "nva" {
  name                 = "nva-nic"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hub_nva_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.nva-pip.id
  }
}

data "template_file" "nva-cloud-init" {
  template = file("./scripts/nva-cloud-init.yaml")
  vars = {
    nva_asn           = var.nva_asn
    rs_ip1            = "10.1.1.4"
    rs_ip2            = "10.1.1.5"
    route_to_announce = var.route_to_announce
    nva_vm_ip         = azurerm_network_interface.nva.private_ip_address
    nva_gw            = var.hub_nva_subnet_gw
    test_vm_ip        = azurerm_network_interface.vm1.private_ip_address
  }
}

resource "azurerm_linux_virtual_machine" "nva" {
  name                = "nva-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = var.vm_admin_username
  network_interface_ids = [
    azurerm_network_interface.nva.id,
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

  custom_data = base64encode(data.template_file.nva-cloud-init.rendered)
}

output "nva-connect" {
  value = "ssh -p2222 ${var.vm_admin_username}@${azurerm_public_ip.nva-pip.ip_address}"
}


resource "azurerm_route_server_bgp_connection" "rs-bgp-connection" {
  name            = "rs-bgp-connection"
  route_server_id = azurerm_route_server.route-server.id
  peer_asn        = var.nva_asn
  peer_ip         = azurerm_network_interface.nva.private_ip_address
}

resource "azurerm_route_table" "nva-rt" {
  name                          = "nva-rt"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  disable_bgp_route_propagation = true

  route {
    name           = "Bypass"
    address_prefix = "${var.my_ip}/32"
    next_hop_type  = "Internet"
  }
}

resource "azurerm_subnet_route_table_association" "nva-rt" {
  subnet_id      = azurerm_subnet.hub_nva_subnet.id
  route_table_id = azurerm_route_table.nva-rt.id
}