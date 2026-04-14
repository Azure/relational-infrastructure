locals {
  network_names = {
    for network_key, network in var.virtual_networks
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

<<<<<<< HEAD:locals.names.tf
  security_group_names = {
    for nsg_key, nsg in var.network_security_groups
    : nsg_key => (
      replace(
        "${var.deployment_prefix}-${nsg_key}-nsg",
=======
  network_security_group_names = {
    for nsg_name, nsg in var.network_security_groups :
    nsg_name => (
      replace(
        nsg.name == null
        ? "${var.deployment_prefix}-${nsg_name}-nsg"
        : (
          nsg.include_deployment_prefix_in_name
          ? "${var.deployment_prefix}-${nsg.name}"
          : nsg.name
        ),
>>>>>>> 2c75bbd6d5bd7303c01c5b6f491bc01cdd013185:subscription_infra_map/locals.names.tf
        "_", "-"
      )
    )
  }

  route_table_names = {
    for table_key, table in var.route_tables
    : table_key => (
      replace(
        "${var.deployment_prefix}-${table_key}-rt",
        "_", "-"
      )
    )
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
    for network_key, network in var.virtual_networks
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
    for network_key, network in var.virtual_networks
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
    for network_key, network in var.virtual_networks
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

  virtual_machine_scale_set_names = {
    for scale_set_name, scale_set in local.virtual_machine_scale_sets
    : scale_set_name => (
      replace(
        scale_set.name == null
        ? "${var.deployment_prefix}-${scale_set_name}-vmss"
        : (
          scale_set.include_deployment_prefix_in_name
          ? "${var.deployment_prefix}-${scale_set.name}-vmss"
          : scale_set.name
        ),
        "_", "-"
      )
    )
  }

  maintenance_configuration_names = {
    for vm_set_name, prefix in local.virtual_machine_set_prefixes
    : vm_set_name => "${prefix}-mc"
  }
}
