variable "environment" {
  type        = string
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

variable "tags" {
  type        = map(string)
}
