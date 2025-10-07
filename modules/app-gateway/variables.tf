
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

variable "public_ip_id" {
  type        = string
}

variable "sku_name" {
  type        = string
}

variable "sku_tier" {
  type        = string
}

variable "capacity" {
  type        = number
}

variable "ssl_certificate_common_name" {
  type        = string
}

variable "ssl_certificate_password" {
  type        = string
  sensitive   = true
}

variable "tags" {
  type        = map(string)
}
