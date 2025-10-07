variable "environment" {
  type        = string
}

variable "project_name" {
  type        = string
}

variable "location" {
  type        = string
}

variable "subnet_id" {
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

variable "admin_password" {
  type        = string
  sensitive   = true
}

variable "acr_name" {
  type        = string
}

variable "acr_username" {
  type        = string
}

variable "acr_password" {
  type        = string
  sensitive   = true
}

variable "docker_image_name" {
  type        = string
}

variable "docker_image_tag" {
  type        = string
}

variable "app_gateway_backend_pool_id" {
  type        = string
}

variable "tags" {
  type        = map(string)
}
