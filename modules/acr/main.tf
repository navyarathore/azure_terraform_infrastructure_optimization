
resource "azurerm_resource_group" "acr_rg" {
  name     = "${var.environment}-${var.project_name}-acr-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_container_registry" "acr" {
  name                = "${var.environment}${var.project_name}acr"
  resource_group_name = azurerm_resource_group.acr_rg.name
  location            = azurerm_resource_group.acr_rg.location
  sku                 = var.sku
  admin_enabled       = true
  tags                = var.tags
}
