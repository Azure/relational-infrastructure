output "resource_groups" {
  value = {
    for group_name, group in var.resource_groups :
    group_name => {
      resource_id   = module.resource_groups[group_name].resource_id
      resource_name = module.resource_groups[group_name].name

      labels = {
        location       = group.location_name
        resource_group = group_name
      }
    }
  }
}

output "networks" {
  value = {
    for network_name, network in var.networks :
    network_name => {
      resource_id   = module.networks[network_name].resource_id
      resource_name = module.networks[network_name].name
      address_space = network.address_space

      labels = {
        location       = network.location_name
        network        = network_name
        resource_group = network.resource_group_name
      }

      subnets = {
        for subnet_name, subnet in network.subnets :
        subnet_name => {
          subnet_id     = module.networks[network_name].subnets[subnet_name].resource_id
          address_space = var.networks[network_name].subnets[subnet_name].address_space

          network_security_group = {
            resource_id   = try(module.network_security_groups["${network_name}_${subnet_name}"].resource_id, null)
            resource_name = try(module.network_security_groups["${network_name}_${subnet_name}"].name, null)
          }

          route_table = {
            resource_id   = try(module.route_tables["${network_name}_${subnet_name}"].resource_id, null)
            resource_name = try(module.route_tables["${network_name}_${subnet_name}"].name, null)
          }
        }
      }
    } if network != null
  }
}

output "ddos_protection_plan" {
  value = {
    resource_id   = try(module.ddos_protection_plan[0].resource_id, null)
    resource_name = try(module.ddos_protection_plan[0].name, null)

    labels = {
      resource_group = var.default_resource_group_name
      location       = keys(var.locations)[0]
    }

  }
}

output "key_vaults" {
  value = {
    for vault_name, vault in var.key_vaults :
    vault_name => {
      resource_id   = module.key_vaults[vault_name].resource_id
      resource_name = module.key_vaults[vault_name].name

      labels = {
        location       = vault.location_name
        resource_group = vault.resource_group_name
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

output "private_endpoints" {
  value = {
    for endpoint_name, endpoint in local.all_private_endpoints :
    endpoint_name => {
      resource_id   = module.private_endpoints[endpoint_name].resource_id
      resource_name = module.private_endpoints[endpoint_name].name
    }
  }
}

output "virtual_machine_sets" {
  value = {
    for vm_set_name, vm_set in var.virtual_machine_sets :
    vm_set_name => {
      resources = module.virtual_machine_sets[vm_set_name]

      labels = {
        location       = vm_set.location_name
        resource_group = vm_set.resource_group_name
        key_vault      = vm_set.key_vault_name
        vm_set         = vm_set_name
      }
    }
  }
}
