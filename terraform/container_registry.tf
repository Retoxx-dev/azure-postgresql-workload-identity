resource "azurerm_container_registry" "this" {
  name                = "cr${replace(local.project_name, "-", "")}"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  sku                 = "Premium"
  admin_enabled       = false

  tags = local.tags
}

# AZURE KUBERNETES SERVICE
resource "azurerm_role_assignment" "aks_nodepool" {
  principal_id                     = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.this.id
  skip_service_principal_aad_check = true
}
