
variable "environment" {
  type        = string
}

variable "project_name" {
  type        = string
}

variable "location" {
  type        = string
}

variable "resource_group_name" {
  type        = string
}

variable "subnet_id" {
  type        = string
}

variable "vm_size" {
  type        = string
}

variable "admin_username" {
  type        = string
}

variable "ssh_public_key" {
  type        = string
}

variable "allowed_ssh_cidr" {
  type        = string
}

variable "tags" {
  type        = map(string)
}
