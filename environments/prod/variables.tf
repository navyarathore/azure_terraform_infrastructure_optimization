
variable "admin_password" {
  type        = string
  sensitive   = true
}

variable "project_name" {
  type        = string
}

variable "location" {
  type        = string
}

variable "vnet_address_space" {
  type        = string
}

variable "public_subnet_cidr" {
  type        = string
}

variable "private_subnet_cidr" {
  type        = string
}

variable "appgw_subnet_cidr" {
  type        = string
}

variable "vm_sku" {
  type        = string
}

variable "instance_count" {
  type        = number
}

variable "availability_zone" {
  type        = string
}

variable "admin_username" {
  type        = string
}

variable "app_gateway_sku_name" {
  type        = string
}

variable "app_gateway_sku_tier" {
  type        = string
}

variable "app_gateway_capacity" {
  type        = number
}

variable "acr_sku" {
  type        = string
}

variable "docker_image_name" {
  type        = string
}

variable "docker_image_tag" {
  type        = string
}

variable "ssh_public_key" {
  type        = string
}

variable "allowed_ssh_cidr" {
  type        = string
}

variable "ssl_certificate_common_name" {
  type        = string
}

variable "ssl_certificate_password" {
  type        = string
  sensitive   = true
}
