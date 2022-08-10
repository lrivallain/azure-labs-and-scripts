# Route Injection VM
resource "azurerm_public_ip" "ri-pip" {
  name                = "ri-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

output "ri-pip" {
  value = azurerm_public_ip.ri-pip.ip_address
}

resource "azurerm_network_interface" "ri" {
  name                = "ri-vm-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hub_ri_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ri-pip.id
  }
}

data "template_file" "cloud-init" {
  template = file("./scripts/ri-cloud-init.yaml")
  vars = {
    azfw_private_ip   = azurerm_firewall.azfw.ip_configuration[0].private_ip_address
    ri_asn            = var.ri_asn
    rs_ip1            = "10.1.1.4"
    rs_ip2            = "10.1.1.5"
    route_to_announce = var.route_to_announce
    ri_vm_ip          = azurerm_network_interface.ri.ip_configuration[0].private_ip_address
  }
}

resource "azurerm_linux_virtual_machine" "ri" {
  name                = "ri-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = var.vm_admin_username
  network_interface_ids = [
    azurerm_network_interface.ri.id,
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

  custom_data = base64encode(data.template_file.cloud-init.rendered)
}

output "ri-connect" {
  value = "ssh ${var.vm_admin_username}@${azurerm_public_ip.ri-pip.ip_address}"
}


resource "azurerm_route_server_bgp_connection" "rs-bgp-connection" {
  name            = "rs-bgp-connection"
  route_server_id = azurerm_route_server.route-server.id
  peer_asn        = var.ri_asn
  peer_ip         = azurerm_linux_virtual_machine.ri.private_ip_address
}

resource "azurerm_route_table" "ri-rt" {
  name                          = "ri-rt"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  disable_bgp_route_propagation = true
}

resource "azurerm_subnet_route_table_association" "ri-rt" {
  subnet_id      = azurerm_subnet.hub_ri_subnet.id
  route_table_id = azurerm_route_table.ri-rt.id
}