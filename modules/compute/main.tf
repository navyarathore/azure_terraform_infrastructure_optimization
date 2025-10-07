resource "azurerm_resource_group" "compute_rg" {
  name     = "${var.environment}-${var.project_name}-compute-rg"
  location = var.location
  tags     = var.tags
}

data "template_cloudinit_config" "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/cloud-init.yaml", {
      acr_name     = var.acr_name
      acr_username = var.acr_username
      acr_password = var.acr_password
      image_name   = var.docker_image_name
      image_tag    = var.docker_image_tag
    })
  }
}

resource "azurerm_network_interface" "vm_nic" {
  count               = var.instance_count
  name                = "${var.environment}-${var.project_name}-vm-nic-${count.index + 1}"
  location            = azurerm_resource_group.compute_rg.location
  resource_group_name = azurerm_resource_group.compute_rg.name
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "vm_nic_appgw" {
  count                   = var.instance_count
  network_interface_id    = azurerm_network_interface.vm_nic[count.index].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = var.app_gateway_backend_pool_id
}

resource "azurerm_linux_virtual_machine" "vm" {
  count               = var.instance_count
  name                = "${var.environment}-${var.project_name}-vm-${count.index + 1}"
  location            = azurerm_resource_group.compute_rg.location
  resource_group_name = azurerm_resource_group.compute_rg.name
  size                = var.vm_sku
  admin_username      = var.admin_username
  zone                = var.availability_zone != "" && var.availability_zone != null ? var.availability_zone : null
  tags                = var.tags

  network_interface_ids = [
    azurerm_network_interface.vm_nic[count.index].id
  ]

  disable_password_authentication = false
  admin_password                  = var.admin_password

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    name                 = "${var.environment}-${var.project_name}-vm-osdisk-${count.index + 1}"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  custom_data = data.template_cloudinit_config.config.rendered

  lifecycle {
    ignore_changes = [
      custom_data
    ]
  }
}
