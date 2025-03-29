locals {
  network_names = {
    for network_name, network in var.networks
    : network_name => (
      replace(
        network.name == null
        ? "${var.deployment_prefix}-${network_name}-vnet"
        : (
          network.include_deployment_prefix_in_name
          ? "${var.deployment_prefix}-${network.name}"
          : network.name
        ),
        "_", "-"
      )
    )
  }

  security_group_names = {
    for network_name, network in var.networks
    : network_name => {
      for subnet_name, subnet in network.subnets
      : subnet_name => (
        replace(
          subnet.security_group_name == null
          ? "${var.deployment_prefix}-${network_name}-${subnet_name}-nsg"
          : (
            network.include_deployment_prefix_in_name
            ? "${var.deployment_prefix}-${subnet.security_group_name}"
            : subnet.security_group_name
          ),
          "_", "-"
        )
      )
    }
  }

  route_table_names = {
    for network_name, network in var.networks
    : network_name => {
      for subnet_name, subnet in network.subnets
      : subnet_name => (
        replace(
          subnet.route_table_name == null
          ? "${var.deployment_prefix}-${network_name}-${subnet_name}-rt"
          : (
            network.include_deployment_prefix_in_name
            ? "${var.deployment_prefix}-${subnet.route_table_name}"
            : subnet.route_table_name
          ),
          "_", "-"
        )
      )
    }
  }

  resource_group_names = {
    for group_name, group in var.resource_groups
    : group_name => (
      replace(
        group.name == null
        ? "${var.deployment_prefix}-${group_name}-rg"
        : (
          group.include_deployment_prefix_in_name
          ? "${var.deployment_prefix}-${group.name}"
          : group.name
        ),
        "_", "-"
      )
    )
  }

  key_vault_names = {
    for vault_name, vault in var.key_vaults
    : vault_name => (
      trim( # Key vault name can't end in a -.
        substr( # Key vault must be 24 characters or less.
          replace( # Replace _ with -. Standardize on - for Azure resource names.
            vault.name == null
            ? "${var.deployment_prefix}-${vault_name}-kv"
            : (
              vault.include_deployment_prefix_in_name
              ? "${var.deployment_prefix}-${vault.name}"
              : vault.name
            ),
            "_", "-"
          )
        , 0, 24)
      , "-")
    )
  }

  key_vault_private_link_names = {
    for network_name, network in var.networks
    : network_name => (
      replace(
        network.name == null
        ? "${var.deployment_prefix}-${network_name}-kv-pl"
        : (
          network.include_deployment_prefix_in_name
          ? "${var.deployment_prefix}-${network.name}-kv-pl"
          : "${network.name}-kv-pl"
        ),
        "_", "-"
      )
    )
  }

  key_vault_private_endpoint_names = {
    for endpoint_name, endpoint in var.private_endpoints.key_vaults
    : endpoint_name => (
      replace(
        endpoint.name == null
        ? "${var.deployment_prefix}-${endpoint_name}-kv-pep"
        : (
          endpoint.include_deployment_prefix_in_name
          ? "${var.deployment_prefix}-${endpoint.name}"
          : endpoint.name
        ),
        "_", "-"
      )
    )
  }

  storage_account_private_endpoint_names = {
    for endpoint_name, endpoint in var.private_endpoints.storage_accounts
    : endpoint_name => (
      replace(
        endpoint.name == null
        ? "${var.deployment_prefix}-${endpoint_name}-st-pep"
        : (
          endpoint.include_deployment_prefix_in_name
          ? "${var.deployment_prefix}-${endpoint.name}"
          : endpoint.name
        ),
        "_", "-"
      )
    )
  }

  virtual_machine_set_prefixes = {
    for vm_set_name, vm_set in var.virtual_machine_sets
    : vm_set_name => (
      replace(
        replace(
          vm_set.name == null
          ? "${var.deployment_prefix}${vm_set_name}"
          : (
            vm_set.include_deployment_prefix_in_name
            ? "${var.deployment_prefix}${vm_set.name}"
            : vm_set.name
          ),
          "_", ""
        ),
        "-", ""
      )
    )
  }

  all_private_endpoint_names = merge(
    local.key_vault_private_endpoint_names,
    local.storage_account_private_endpoint_names
  )
}
