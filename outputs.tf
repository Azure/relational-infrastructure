output "resource_groups" {
  value = {
    for group_name, group in var.resource_groups :
    group_name => {
      resource_id   = module.resource_groups[group_name].resource_id
      resource_name = module.resource_groups[group_name].name

      labels = {
        location       = group.location_key_reference
        resource_group = group_name
      }
    }
  }
}

output "virtual_networks" {
  value = {
    for network_key, network in var.virtual_networks :
    network_key => {
      resource_id   = module.networks[network_key].resource_id
      resource_name = module.networks[network_key].name
      address_space = network.address_space

      labels = {
        location       = network.location_key_reference
        network        = network_key
        resource_group = network.resource_group_key_reference
      }

      subnets = {
        for subnet_key, subnet in network.subnets :
        subnet_key => {
          subnet_id     = module.networks[network_key].subnets[subnet_key].resource_id
          address_space = var.virtual_networks[network_key].subnets[subnet_key].address_space

          network_security_group = {
            resource_id   = try(module.network_security_groups[subnet.network_security_group_key_reference].resource_id, null)
            resource_name = try(module.network_security_groups[subnet.network_security_group_key_reference].name, null)
          }

          route_table = {
            resource_id   = try(module.route_tables[subnet.route_table_key_reference].resource_id, null)
            resource_name = try(module.route_tables[subnet.route_table_key_reference].name, null)
          }

          nat_gateway = {
            resource_id   = try(module.nat_gateways[subnet.nat_gateway_key_reference].resource_id, null)
            resource_name = try(local.nat_gateway_names[subnet.nat_gateway_key_reference], null)
          }
        }
      }
    } if network != null
  }
}

output "ddos_protection_plan" {
  value = (
    try(module.ddos_protection_plan[0].resource_id, null) != null ? {
      resource_id   = module.ddos_protection_plan[0].resource_id
      resource_name = module.ddos_protection_plan[0].name

      labels = {
        resource_group = var.default_resource_group_key_reference
        location       = keys(var.locations)[0]
      }
    } : null
  )
}

output "key_vaults" {
  value = {
    for vault_name, vault in var.key_vaults :
    vault_name => {
      resource_id   = module.key_vaults[vault_name].resource_id
      resource_name = module.key_vaults[vault_name].name

      labels = {
        location       = vault.location_key_reference
        resource_group = vault.resource_group_key_reference
      }

      secrets = {
        for secret_name, secret_id in module.key_vaults[vault_name].secrets_resource_ids :
        secret_name => {
          resource_id = secret_id
        }
      }
    }
  }
}

output "storage_accounts" {
  value = {
    for account_name, account in var.storage_accounts :
    account_name => {
      resource_id   = module.storage_accounts[account_name].resource_id
      resource_name = module.storage_accounts[account_name].name

      blob_containers = {
        for container_key, container in module.storage_accounts[account_name].containers :
        container_key => {
          resource_id = container.id
        }
      }

      file_shares = {
        for share_key, share in module.storage_accounts[account_name].shares :
        share_key => {
          resource_id = share.id
        }
      }

      labels = {
        location        = account.location_key_reference
        resource_group  = account.resource_group_key_reference
        storage_account = account_name
      }
    }
  }
}

output "virtual_machine_sets" {
  value = {
    for vm_set_name, vm_set in var.virtual_machine_sets :
    vm_set_name => {
      resources = module.virtual_machine_sets[vm_set_name]

      labels = {
        location       = vm_set.location_key_reference
        resource_group = vm_set.resource_group_key_reference
        key_vault      = vm_set.key_vault_key_reference
        vm_set         = vm_set_name
      }
    }
  }
}

output "load_balancers" {
  value = {
    for lb_key, lb in var.load_balancers :
    lb_key => {
      resource_id   = module.load_balancers[lb_key].resource_id
      resource_name = local.load_balancer_names[lb_key]
      type          = lb.type

      labels = {
        load_balancer  = lb_key
        location       = lb.location_key_reference
        resource_group = lb.resource_group_key_reference
      }

      frontend_ip_configurations = {
        for fe_key, fe in lb.frontend_ip_configurations :
        fe_key => {
          name = local.load_balancer_frontend_configs[lb_key][fe_key].name
          public_ip = (
            lb.type == "external"
            ? {
              resource_id = module.load_balancers[lb_key].azurerm_public_ip[fe_key].id
              ip_address  = module.load_balancers[lb_key].azurerm_public_ip[fe_key].ip_address
              fqdn        = module.load_balancers[lb_key].azurerm_public_ip[fe_key].fqdn
            }
            : null
          )
          private_ip_address = lb.type == "internal" ? fe.private_ip_address : null
        }
      }

      backend_pools = {
        for pool_key, pool in lb.backend_pools :
        pool_key => {
          resource_id = module.load_balancers[lb_key].azurerm_lb_backend_address_pool[pool_key].id
          name        = local.load_balancer_backend_pools[lb_key][pool_key].name
        }
      }
    }
  }
}

output "nat_gateways" {
  value = {
    for nat_key, nat in var.nat_gateways :
    nat_key => {
      resource_id   = module.nat_gateways[nat_key].resource_id
      resource_name = local.nat_gateway_names[nat_key]
      sku_name      = nat.sku_name

      labels = {
        nat_gateway    = nat_key
        location       = nat.location_key_reference
        resource_group = nat.resource_group_key_reference
      }

      public_ips = {
        for pip_key, pip in nat.public_ips :
        pip_key => {
          resource_id = module.nat_gateways[nat_key].public_ip_resource[pip_key].id
          ip_address  = try(module.nat_gateways[nat_key].public_ip_resource[pip_key].ip_address, module.nat_gateways[nat_key].public_ip_resource[pip_key].properties.ipAddress, null)
          fqdn        = try(module.nat_gateways[nat_key].public_ip_resource[pip_key].fqdn, null)
        }
      }
    }
  }
}
