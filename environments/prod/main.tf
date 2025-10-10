
module "acr" {
  source = "../../modules/acr"

  environment  = local.environment
  project_name = local.project_name
  location     = local.location
  sku          = local.acr_sku
  tags         = local.tags
}

module "networking" {
  source = "../../modules/networking"

  environment         = local.environment
  project_name        = local.project_name
  location            = local.location
  vnet_address_space  = local.vnet_address_space
  public_subnet_cidr  = local.public_subnet_cidr
  private_subnet_cidr = local.private_subnet_cidr
  appgw_subnet_cidr   = local.appgw_subnet_cidr
  tags                = local.tags
}

module "bastion" {
  source = "../../modules/bastion"

  environment         = local.environment
  project_name        = local.project_name
  location            = local.location
  resource_group_name = module.networking.resource_group_name
  subnet_id           = module.networking.public_subnet_id
  vm_size             = local.bastion_vm_size
  admin_username      = local.admin_username
  ssh_public_key      = local.ssh_public_key
  allowed_ssh_cidr    = local.allowed_ssh_cidr
  tags                = local.tags

  depends_on = [module.networking]
}

module "app_gateway" {
  source = "../../modules/app-gateway"

  environment                 = local.environment
  project_name                = local.project_name
  location                    = local.location
  subnet_id                   = module.networking.appgw_subnet_id
  public_ip_id                = module.networking.app_gateway_public_ip_id
  sku_name                    = local.app_gateway_sku_name
  sku_tier                    = local.app_gateway_sku_tier
  capacity                    = local.app_gateway_capacity
  ssl_certificate_common_name = local.ssl_certificate_common_name
  ssl_certificate_password    = local.ssl_certificate_password
  tags                        = local.tags

  depends_on = [module.networking]
}

module "compute" {
  source = "../../modules/compute"

  environment                 = local.environment
  project_name                = local.project_name
  location                    = local.location
  subnet_id                   = module.networking.private_subnet_id
  vm_sku                      = local.vm_sku
  instance_count              = local.instance_count
  availability_zone           = local.availability_zone
  admin_username              = local.admin_username
  admin_password              = var.admin_password
  acr_name                    = module.acr.acr_name
  acr_username                = module.acr.acr_admin_username
  acr_password                = module.acr.acr_admin_password
  docker_image_name           = local.docker_image_name
  docker_image_tag            = local.docker_image_tag
  app_gateway_backend_pool_id = module.app_gateway.backend_address_pool_id
  tags                        = local.tags

  depends_on = [module.networking, module.app_gateway, module.acr]
}
