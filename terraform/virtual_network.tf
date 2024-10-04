module "virtual_network" {
  source  = "Retoxx-dev/virtual-network/azurerm"
  version = "1.0.3"

  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location

  name = "vnet-${local.project_name}"

  address_space = ["10.0.0.0/22"]

  subnets = [
    {
      name             = "snet-${local.project_name}-kubernetes"
      address_prefixes = [cidrsubnet("10.0.0.0/22", 2, 0)]
    },
    {
      name             = "snet-${local.project_name}-postgresql"
      address_prefixes = [cidrsubnet("10.0.0.0/22", 5, 8)]
      subnet_delegations = [
        {
          name            = "PostgresqlFlexibleServer"
          service_name    = "Microsoft.DBforPostgreSQL/flexibleServers"
          service_actions = ["Microsoft.Network/virtualNetworks/subnets/join/action"]
        }
      ]
      service_endpoints = ["Microsoft.Storage"]
    },
    {
      name             = "snet-${local.project_name}-bastion"
      address_prefixes = [cidrsubnet("10.0.0.0/22", 5, 9)]
    }
  ]

  security_groups = [
    {
      name      = "sg-${local.project_name}-bastion"
      assign_to = "snet-${local.project_name}-bastion"
      rules = [
        {
          name                       = "AllowSSH"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = local.authorized_ip
          destination_address_prefix = "*"
        }
      ]
    },
    {
      name      = "sg-${local.project_name}-postgresql"
      assign_to = "snet-${local.project_name}-postgresql"
      rules = [
        {
          name                       = "AllowBastionInbound"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "5432"
          source_address_prefix      = cidrsubnet("10.0.0.0/22", 5, 9)
          destination_address_prefix = cidrsubnet("10.0.0.0/22", 5, 8)
        },
        {
          name                       = "AllowKubernetesInbound"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "5432"
          source_address_prefix      = cidrsubnet("10.0.0.0/22", 2, 0)
          destination_address_prefix = cidrsubnet("10.0.0.0/22", 5, 8)
        },
        {
          name                       = "AllowInSubnetInbound"
          priority                   = 115
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = cidrsubnet("10.0.0.0/22", 5, 8)
          destination_address_prefix = cidrsubnet("10.0.0.0/22", 5, 8)
        },
        {
          name                       = "DenyAllInbound"
          priority                   = 120
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        },
        {
          name                       = "AllowInSubnetOutbound"
          priority                   = 105
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = cidrsubnet("10.0.0.0/22", 5, 8)
          destination_address_prefix = cidrsubnet("10.0.0.0/22", 5, 8)
        },
        {
          name                       = "AllowStorageOutbound"
          priority                   = 106
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "Storage"
        },
        {
          name                       = "AllowEntraIDOutbound"
          priority                   = 107
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "AzureActiveDirectory"
        },
        {
          name                       = "DenyAllOutbound"
          priority                   = 108
          direction                  = "Outbound"
          access                     = "Deny"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
  ]

  tags = local.tags
}
