resource "azurerm_user_assigned_identity" "this" {
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name
  name                = "id-${local.project_name}-app"

  tags = local.tags
}

resource "azurerm_federated_identity_credential" "this" {
  name                = "fid-${local.project_name}-app"
  resource_group_name = azurerm_resource_group.this.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.this.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.this.id
  subject             = "system:serviceaccount:app:app"
}
