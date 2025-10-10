
output "bastion_public_ip" {
  description = "Public IP address of the Bastion Host"
  value       = module.bastion.bastion_public_ip
}

output "bastion_ssh_command" {
  description = "SSH command to connect to bastion host"
  value       = module.bastion.ssh_command
}

output "app_gateway_public_ip" {
  description = "Public IP address of the Application Gateway"
  value       = module.networking.app_gateway_public_ip_address
}

output "acr_login_server" {
  description = "Login server URL for the Azure Container Registry"
  value       = module.acr.acr_login_server
}

output "acr_name" {
  description = "Name of the Azure Container Registry"
  value       = module.acr.acr_name
}

output "vm_names" {
  description = "Names of the Virtual Machines"
  value       = module.compute.vm_names
}

output "vm_private_ips" {
  description = "Private IP addresses of the VMs"
  value       = module.compute.vm_private_ips
}

output "resource_group_names" {
  description = "Names of all resource groups created"
  value = {
    network     = module.networking.resource_group_name
    compute     = module.compute.resource_group_name
    app_gateway = module.app_gateway.resource_group_name
    acr         = module.acr.resource_group_name
  }
}
