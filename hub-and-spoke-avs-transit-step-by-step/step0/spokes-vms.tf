data "template_file" "test-cloud-init" {
  template = file("./scripts/test-cloud-init.yaml")
  vars = {
    admin_user     = "ubuntu" # Temp: see https://github.com/hashicorp/terraform-provider-azurerm/issues/18069
    admin_password = var.vm_ubuntu_password
    ssh_key        = file("~/.ssh/id_rsa.pub")
  }
}

# VM1
resource "azurerm_network_interface" "spoke_1_vm" {
  name                = "${var.spoke_1_vnet}-vm-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.spoke_1_test_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "spoke_1_vm" {
  name                = "${var.spoke_1_vnet}-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = var.vm_admin_username
  network_interface_ids = [
    azurerm_network_interface.spoke_1_vm.id,
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

  custom_data = base64encode(data.template_file.test-cloud-init.rendered)
}

# VM2
resource "azurerm_network_interface" "spoke_2_vm" {
  name                = "${var.spoke_2_vnet}-vm-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.spoke_2_test_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "spoke_2_vm" {
  name                = "${var.spoke_2_vnet}-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = var.vm_admin_username
  network_interface_ids = [
    azurerm_network_interface.spoke_2_vm.id,
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

  custom_data = base64encode(data.template_file.test-cloud-init.rendered)
}