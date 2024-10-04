resource "azurerm_kubernetes_cluster" "this" {
  name                      = "aks-${local.project_name}"
  location                  = azurerm_resource_group.this.location
  resource_group_name       = azurerm_resource_group.this.name
  dns_prefix                = "aks-${local.project_name}"
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_D2s_v3"
    vnet_subnet_id = module.virtual_network.subnet_ids["snet-${local.project_name}-kubernetes"]

    upgrade_settings {
      drain_timeout_in_minutes      = 0
      max_surge                     = "10%"
      node_soak_duration_in_minutes = 0
    }
  }

  api_server_access_profile {
    authorized_ip_ranges = [local.authorized_ip]
  }

  network_profile {
    network_plugin = "azure"
    dns_service_ip = "10.2.0.10"
    outbound_type  = "loadBalancer"
    service_cidr   = "10.2.0.0/24"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}
