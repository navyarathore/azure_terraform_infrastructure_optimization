locals {
  environment  = "dev"
  project_name = var.project_name
  location     = var.location

  tags = {
    Environment = "dev"
    Project     = "${var.project_name}-nr"
  }

  vnet_address_space  = var.vnet_address_space
  public_subnet_cidr  = var.public_subnet_cidr
  private_subnet_cidr = var.private_subnet_cidr
  appgw_subnet_cidr   = var.appgw_subnet_cidr

  vm_sku            = var.vm_sku
  instance_count    = var.instance_count
  availability_zone = var.availability_zone
  admin_username    = var.admin_username

  app_gateway_sku_name = var.app_gateway_sku_name
  app_gateway_sku_tier = var.app_gateway_sku_tier
  app_gateway_capacity = var.app_gateway_capacity

  acr_sku = var.acr_sku

  docker_image_name = var.docker_image_name
  docker_image_tag  = var.docker_image_tag

  ssh_public_key   = var.ssh_public_key
  allowed_ssh_cidr = var.allowed_ssh_cidr
  bastion_vm_size  = "Standard_B1s"

  ssl_certificate_common_name = var.ssl_certificate_common_name
  ssl_certificate_password    = var.ssl_certificate_password
}
