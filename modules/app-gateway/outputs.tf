
output "app_gateway_id" {
  description = "ID of the Application Gateway"
  value       = azurerm_application_gateway.app_gateway.id
}

output "app_gateway_name" {
  description = "Name of the Application Gateway"
  value       = azurerm_application_gateway.app_gateway.name
}

output "backend_address_pool_id" {
  description = "ID of the backend address pool"
  value       = tolist(azurerm_application_gateway.app_gateway.backend_address_pool)[0].id
}

output "resource_group_name" {
  description = "Name of the Application Gateway resource group"
  value       = azurerm_resource_group.appgw_rg.name
}

output "https_health_probe_id" {
  description = "ID of the HTTPS health probe"
  value       = "${azurerm_application_gateway.app_gateway.id}/probes/https-health-probe"
}
