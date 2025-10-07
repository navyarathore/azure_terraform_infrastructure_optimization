output "vm_ids" {
  description = "IDs of the Virtual Machines"
  value       = azurerm_linux_virtual_machine.vm[*].id
}

output "vm_names" {
  description = "Names of the Virtual Machines"
  value       = azurerm_linux_virtual_machine.vm[*].name
}

output "vm_private_ips" {
  description = "Private IP addresses of the Virtual Machines"
  value       = azurerm_network_interface.vm_nic[*].private_ip_address
}

output "resource_group_name" {
  description = "Name of the compute resource group"
  value       = azurerm_resource_group.compute_rg.name
}

output "availability_zone" {
  description = "Availability Zone used for VMs"
  value       = var.availability_zone
}
