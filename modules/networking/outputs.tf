output "resource_group_name" {
  description = "Name of the network resource group"
  value       = azurerm_resource_group.network_rg.name
}

output "vnet_id" {
  description = "ID of the Virtual Network"
  value       = azurerm_virtual_network.vnet.id
}

output "vnet_name" {
  description = "Name of the Virtual Network"
  value       = azurerm_virtual_network.vnet.name
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = azurerm_subnet.public_subnet.id
}

output "public_subnet_name" {
  description = "Name of the public subnet"
  value       = azurerm_subnet.public_subnet.name
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = azurerm_subnet.private.id
}

output "private_subnet_name" {
  description = "Name of the private subnet"
  value       = azurerm_subnet.private.name
}

output "appgw_subnet_id" {
  description = "ID of the Application Gateway dedicated subnet"
  value       = azurerm_subnet.appgw_subnet.id
}

output "appgw_subnet_name" {
  description = "Name of the Application Gateway dedicated subnet"
  value       = azurerm_subnet.appgw_subnet.name
}

output "app_gateway_public_ip_id" {
  description = "ID of the Application Gateway Public IP"
  value       = azurerm_public_ip.app_gateway_pip.id
}

output "app_gateway_public_ip_address" {
  description = "Public IP address of the Application Gateway"
  value       = azurerm_public_ip.app_gateway_pip.ip_address
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway"
  value       = azurerm_nat_gateway.nat_gateway.id
}

output "location" {
  description = "Azure region location"
  value       = azurerm_resource_group.network_rg.location
}
