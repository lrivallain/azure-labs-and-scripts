# Route Injection VM
resource "azurerm_public_ip" "hub_nva_vm_pip" {
  name                = "hub-nva-vm-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

output "hub_nva_vm_pip" {
  value = azurerm_public_ip.hub_nva_vm_pip.ip_address
}

resource "azurerm_network_interface" "hub_nva_vm" {
  name                 = "hub-nva-nic"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  enable_ip_forwarding = true

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hub_nva_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.hub_nva_vm_pip.id
  }
}

data "template_file" "hub_nva_cloud_init" {
  template = file("./scripts/hub-nva-cloud-init.yaml")
  vars = {
    admin_user        = "ubuntu" # Temp: see https://github.com/hashicorp/terraform-provider-azurerm/issues/18069
    admin_password    = var.vm_ubuntu_password
    ssh_key           = file("~/.ssh/id_rsa.pub")
    local_asn         = var.hub_nva_vm_asn
    rs_asn            = var.hub_route_server_asn
    rs_ip1            = var.hub_route_server_ip1
    rs_ip2            = var.hub_route_server_ip2
    route_to_announce = var.azure_global_prefix
    vm_ip             = azurerm_network_interface.hub_nva_vm.private_ip_address
    gw                = var.hub_nva_subnet_gw
  }
}

resource "azurerm_linux_virtual_machine" "hub_nva_vm" {
  name                = "hub-nva"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = var.vm_size
  admin_username      = var.vm_admin_username
  network_interface_ids = [
    azurerm_network_interface.hub_nva_vm.id,
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

  custom_data = base64encode(data.template_file.hub_nva_cloud_init.rendered)
}

output "hub_nva_connect" {
  value = "ssh -p2222 ubuntu@${azurerm_public_ip.hub_nva_vm_pip.ip_address}"
}

resource "azurerm_route_table" "hub_nva_rt" {
  name                          = "hub-nva-rt"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  disable_bgp_route_propagation = false

  route {
    name                   = "AVSMgntGoesThroughAVSNVA"
    address_prefix         = var.avs_mgnt_route_to_announce
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_network_interface.avs_bgp_vm.private_ip_address
  }

  route {
    name                   = "AVSWkldGoesThroughAVSNVA"
    address_prefix         = var.avs_wkld_route_to_announce
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_network_interface.avs_bgp_vm.private_ip_address
  }
}

resource "azurerm_subnet_route_table_association" "hub_nva_rt" {
  subnet_id      = azurerm_subnet.hub_nva_subnet.id
  route_table_id = azurerm_route_table.hub_nva_rt.id
}