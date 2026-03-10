locals {
  network_names = {
    for network_key, network in var.networks
    : network_key => (
      replace(
        network.name == null
        ? "${var.deployment_prefix}-${network_key}-vnet"
        : (
          network.include_deployment_prefix_in_name
          ? "${var.deployment_prefix}-${network.name}"
          : network.name
        ),
        "_", "-"
      )
    )
  }

  storage_account_names = {
    for account_name, account in var.storage_accounts
    : account_name => (
      substr(
        replace(replace(
          (
            account.name == null
            ? "${var.deployment_prefix}${account_name}"
            : (
              account.include_deployment_prefix_in_name
              ? "${var.deployment_prefix}${account.name}"
              : account.name
            )
          )
        , "-", ""), "_", ""),
      0, 24)
    )
  }

  security_group_names = {
    for network_key, network in var.networks
    : network_key => {
      for subnet_key, subnet in network.subnets
      : subnet_key => (
        replace(
          subnet.security_group_name == null
          ? "${var.deployment_prefix}-${network_key}-${subnet_key}-nsg"
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
    for network_key, network in var.networks
    : network_key => {
      for subnet_key, subnet in network.subnets
      : subnet_key => (
        replace(
          subnet.route_table_name == null
          ? "${var.deployment_prefix}-${network_key}-${subnet_key}-rt"
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
      trim(        # Key vault name can't end in a -.
        substr(    # Key vault must be 24 characters or less.
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

  blob_storage_private_link_names = {
    for network_key, network in var.networks
    : network_key => (
      replace(
        network.name == null
        ? "${var.deployment_prefix}-${network_key}-st-blob-pl"
        : (
          network.include_deployment_prefix_in_name
          ? "${var.deployment_prefix}-${network.name}-st-blob-pl"
          : "${network.name}-st-blob-pl"
        ),
        "_", "-"
      )
    )
  }

  file_share_private_link_names = {
    for network_key, network in var.networks
    : network_key => (
      replace(
        network.name == null
        ? "${var.deployment_prefix}-${network_key}-st-share-pl"
        : (
          network.include_deployment_prefix_in_name
          ? "${var.deployment_prefix}-${network.name}-st-share-pl"
          : "${network.name}-st-share-pl"
        ),
        "_", "-"
      )
    )
  }

  key_vault_private_link_names = {
    for network_key, network in var.networks
    : network_key => (
      replace(
        network.name == null
        ? "${var.deployment_prefix}-${network_key}-kv-pl"
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

  blob_container_private_endpoint_names = {
    for pe_name, pe in var.private_endpoints.blob_containers
    : pe_name => (
      replace(
        pe.name == null
        ? "${var.deployment_prefix}-${pe_name}-st-blob-pep"
        : (
          pe.include_deployment_prefix_in_name
          ? "${var.deployment_prefix}-${pe.name}"
          : pe.name
        ),
        "_", "-"
      )
    )
  }

  file_share_private_endpoint_names = {
    for pe_name, pe in var.private_endpoints.file_shares
    : pe_name => (
      replace(
        pe.name == null
        ? "${var.deployment_prefix}-${pe_name}-st-share-pep"
        : (
          pe.include_deployment_prefix_in_name
          ? "${var.deployment_prefix}-${pe.name}"
          : pe.name
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

  virtual_machine_set_asg_names = {
    for vm_set_name, vm_set in var.virtual_machine_sets
    : vm_set_name => (
      replace(
        vm_set.name == null
        ? "${var.deployment_prefix}-${vm_set_name}-asg"
        : (
          vm_set.include_deployment_prefix_in_name
          ? "${var.deployment_prefix}-${vm_set.name}-asg"
          : "${vm_set.name}-asg"
        ),
        "_", "-"
      )
    )
  }

  maintenance_configuration_names = {
    for vm_set_name, prefix in local.virtual_machine_set_prefixes
    : vm_set_name => "${prefix}-mc"
  }

  all_private_endpoint_names = merge(
    local.key_vault_private_endpoint_names,
    local.blob_container_private_endpoint_names,
    local.file_share_private_endpoint_names
  )
}
