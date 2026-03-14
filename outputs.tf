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
