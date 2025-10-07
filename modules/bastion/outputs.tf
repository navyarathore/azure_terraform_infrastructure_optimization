
output "bastion_public_ip" {
  description = "Public IP address of the bastion host"
  value       = azurerm_public_ip.bastion_pip.ip_address
}

output "bastion_vm_id" {
  description = "Resource ID of the bastion VM"
  value       = azurerm_linux_virtual_machine.bastion.id
}

output "bastion_vm_name" {
  description = "Name of the bastion VM"
  value       = azurerm_linux_virtual_machine.bastion.name
}

output "bastion_private_ip" {
  description = "Private IP address of the bastion host"
  value       = azurerm_network_interface.bastion_nic.private_ip_address
}

output "ssh_command" {
  description = "SSH command to connect to bastion host"
  value       = "ssh -i <your-key.pem> ${var.admin_username}@${azurerm_public_ip.bastion_pip.ip_address}"
}
