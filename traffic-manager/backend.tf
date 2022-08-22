resource "azurerm_public_ip" "web-pip" {
  count               = var.web_workers_count
  name                = "web-pip-${count.index + 1}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
  domain_name_label   = "atm-web-${count.index + 1}"
}

resource "azurerm_network_interface" "nic" {
  count               = var.web_workers_count
  name                = "nic-${count.index + 1}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "nic-ipconfig-${count.index + 1}"
    subnet_id                     = azurerm_subnet.backend.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.web-pip[count.index].id
  }
}

data "template_file" "test-cloud-init" {
  template = file("./scripts/web-worker-cloud-init.yaml")
}

resource "azurerm_linux_virtual_machine" "web-worker" {
  count                           = var.web_workers_count
  name                            = "web-${count.index + 1}"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  size                            = var.vm_size
  admin_username                  = var.vm_admin_username
  admin_password                  = random_password.password.result
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
  ]

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