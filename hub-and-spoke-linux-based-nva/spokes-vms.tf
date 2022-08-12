# VM1
resource "azurerm_public_ip" "vm1-pip" {
  name                = "${var.spoke_1_vnet}-vm-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

output "vm1-pip" {
  value = azurerm_public_ip.vm1-pip.ip_address
}

resource "azurerm_network_interface" "vm1" {
  name                = "${var.spoke_1_vnet}-vm-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.spoke_1_test_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm1-pip.id
  }
}

data "template_file" "test-cloud-init" {
  template = file("./scripts/test-cloud-init.yaml")
}

resource "azurerm_linux_virtual_machine" "vm1" {
  name                = "${var.spoke_1_vnet}-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = var.vm_admin_username
  network_interface_ids = [
    azurerm_network_interface.vm1.id,
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

  custom_data = base64encode(data.template_file.test-cloud-init.rendered)
}

output "vm1-connect" {
  value = "ssh -p2222 ${var.vm_admin_username}@${azurerm_public_ip.vm1-pip.ip_address}"
}