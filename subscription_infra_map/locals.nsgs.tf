locals {
  allow_in_security_rules = {
    for rule_name, rule in var.network_security_rules : rule_name => {
      access    = "Allow"
      direction = "Inbound"
      protocol  = rule.protocol
      from      = rule.allow.in.from
      to        = rule.allow.in.to

      destination_port_names = try(coalesce(
        rule.allow.in.to.port_names,
        rule.allow.in.to.port_name != null ? [rule.allow.in.to.port_name] : null,
        rule.port_names,
        rule.port_name != null ? [rule.port_name] : null
      ), null)

      source_port_names = try(coalesce(
        rule.allow.in.from.port_names,
        rule.allow.in.from.port_name != null ? [rule.allow.in.from.port_name] : null
      ), null)

    } if try(rule.allow.in != null, false)
  }

  allow_out_security_rules = {
    for rule_name, rule in var.network_security_rules : rule_name => {
      access    = "Allow"
      direction = "Outbound"
      protocol  = rule.protocol
      from      = rule.allow.out.from
      to        = rule.allow.out.to

      destination_port_names = try(coalesce(
        rule.allow.out.to.port_names,
        rule.allow.out.to.port_name != null ? [rule.allow.out.to.port_name] : null,
        rule.port_names,
        rule.port_name != null ? [rule.port_name] : null
      ), null)

      source_port_names = try(coalesce(
        rule.allow.out.from.port_names,
        rule.allow.out.from.port_name != null ? [rule.allow.out.from.port_name] : null
      ), null)

    } if try(rule.allow.out != null, false)
  }

  deny_in_security_rules = {
    for rule_name, rule in var.network_security_rules : rule_name => {
      access    = "Deny"
      direction = "Inbound"
      protocol  = rule.protocol
      from      = rule.deny.in.from
      to        = rule.deny.in.to

      destination_port_names = try(coalesce(
        rule.deny.in.to.port_names,
        rule.deny.in.to.port_name != null ? [rule.deny.in.to.port_name] : null,
        rule.port_names,
        rule.port_name != null ? [rule.port_name] : null
      ), null)

      source_port_names = try(coalesce(
        rule.deny.in.from.port_names,
        rule.deny.in.from.port_name != null ? [rule.deny.in.from.port_name] : null
      ), null)

    } if try(rule.deny.in != null, false)
  }

  deny_out_security_rules = {
    for rule_name, rule in var.network_security_rules : rule_name => {
      access    = "Deny"
      direction = "Outbound"
      protocol  = rule.protocol
      from      = rule.deny.out.from
      to        = rule.deny.out.to

      destination_port_names = try(coalesce(
        rule.deny.out.to.port_names,
        rule.deny.out.to.port_name != null ? [rule.deny.out.to.port_name] : null,
        rule.port_names,
        rule.port_name != null ? [rule.port_name] : null
      ), null)

      source_port_names = try(coalesce(
        rule.deny.out.from.port_names,
        rule.deny.out.from.port_name != null ? [rule.deny.out.from.port_name] : null
      ), null)

    } if try(rule.deny.out != null, false)
  }

  security_rule_port_ranges = {
    for rule_name, rule in merge(
      local.allow_in_security_rules,
      local.allow_out_security_rules,
      local.deny_in_security_rules,
      local.deny_out_security_rules
      ) : rule_name => {

      destination_port_range = (rule.destination_port_names == null ? "*" : null)
      source_port_range      = (rule.source_port_names == null ? "*" : null)

      destination_port_ranges = (
        rule.destination_port_names == null ? null :
        [for port_name in rule.destination_port_names : var.network_ports[port_name]]
      )

      source_port_ranges = (
        rule.source_port_names == null ? null :
        [for port_name in rule.source_port_names : var.network_ports[port_name]]
      )
    }
  }

  security_rule_destinations = {
    for rule_name, rule in merge(
      local.allow_in_security_rules,
      local.allow_out_security_rules,
      local.deny_in_security_rules,
      local.deny_out_security_rules
      ) : rule_name => (
      rule.to == null
      ? local.default_network_tuple
      : (
        rule.to.address_space != null
        ? {
          app_security_group_ids = null
          address_spaces         = [rule.to.address_space]
          port_range             = local.security_rule_port_ranges[rule_name].destination_port_range
          port_ranges            = local.security_rule_port_ranges[rule_name].destination_port_ranges
        }
        : (
          rule.to.subnet != null
          ? {
            app_security_group_ids = null
            address_spaces         = [local.network_address_spaces[rule.to.subnet.network_name].subnets[rule.to.subnet.subnet_name].address_space]
            port_range             = local.security_rule_port_ranges[rule_name].destination_port_range
            port_ranges            = local.security_rule_port_ranges[rule_name].destination_port_ranges
          }
          : (
            rule.to.network != null
            ? {
              app_security_group_ids = null
              address_spaces         = local.network_address_spaces[rule.to.network.name].address_spaces
              port_range             = local.security_rule_port_ranges[rule_name].destination_port_range
              port_ranges            = local.security_rule_port_ranges[rule_name].destination_port_ranges
            }
            : {
              app_security_group_ids = [azurerm_application_security_group.application_security_group[rule.to.vm_set.name].id]
              address_spaces         = []
              port_range             = local.security_rule_port_ranges[rule_name].destination_port_range
              port_ranges            = local.security_rule_port_ranges[rule_name].destination_port_ranges
            }
          )
        )
      )
    )
  }

  security_rule_sources = {
    for rule_name, rule in merge(
      local.allow_in_security_rules,
      local.allow_out_security_rules,
      local.deny_in_security_rules,
      local.deny_out_security_rules
      ) : rule_name => (
      rule.from == null
      ? local.default_network_tuple
      : (
        rule.from.address_space != null
        ? {
          app_security_group_ids = []
          address_spaces         = [rule.from.address_space]
          port_ranges            = local.security_rule_port_ranges[rule_name].source_port_ranges
          port_range             = local.security_rule_port_ranges[rule_name].source_port_range
        }
        : (
          rule.from.subnet != null
          ? {
            app_security_group_ids = []
            address_spaces         = [local.network_address_spaces[rule.from.subnet.network_name].subnets[rule.from.subnet.subnet_name].address_space]
            port_ranges            = local.security_rule_port_ranges[rule_name].source_port_ranges
            port_range             = local.security_rule_port_ranges[rule_name].source_port_range
          }
          : (
            rule.from.network != null
            ? {
              app_security_group_ids = []
              address_spaces         = local.network_address_spaces[rule.from.network.name].address_spaces
              port_ranges            = local.security_rule_port_ranges[rule_name].source_port_ranges
              port_range             = local.security_rule_port_ranges[rule_name].source_port_range
            }
            : {
              app_security_group_ids = [azurerm_application_security_group.application_security_group[rule.from.vm_set.name].id]
              address_spaces         = []
              port_ranges            = local.security_rule_port_ranges[rule_name].source_port_ranges
              port_range             = local.security_rule_port_ranges[rule_name].source_port_range
            }
          )
        )
      )
    )
  }

  security_rule_config = {
    for rule_name, rule in merge(
      local.allow_in_security_rules,
      local.allow_out_security_rules,
      local.deny_in_security_rules,
      local.deny_out_security_rules
      ) : rule_name => {
      access                                     = rule.access
      direction                                  = rule.direction
      protocol                                   = rule.protocol
      destination_address_prefixes               = local.security_rule_destinations[rule_name].address_spaces
      destination_application_security_group_ids = local.security_rule_destinations[rule_name].app_security_group_ids
      destination_port_ranges                    = local.security_rule_destinations[rule_name].port_ranges
      source_address_prefixes                    = local.security_rule_sources[rule_name].address_spaces
      source_application_security_group_ids      = local.security_rule_sources[rule_name].app_security_group_ids
      source_port_ranges                         = local.security_rule_sources[rule_name].port_ranges
    }
  }

  network_security_groups = tomap({
    for group in flatten([
      for network_ref, network in local.networks : [
        for subnet_ref, subnet in network.subnets : {
          location_ref        = network.location_name
          network_ref         = network_ref
          subnet_ref          = subnet_ref
          subnet_name         = subnet.name
          name                = local.security_group_names[network_ref][subnet_ref]
          resource_group_name = network.resource_group_name
          tags                = network.tags
          lock                = network.lock

          security_rules = {
            for rule_index, rule_name in subnet.security_rules : rule_name => {
              priority = (100 + (rule_index * 5)) // Start at 100. Increment by 5 to leave room for future additions.
              config   = local.security_rule_config[rule_name]
            }
          }

        } if !contains(local.no_network_security_group_subnets, lower(subnet.name))
      ] if network != null
    ]) : "${group.network_ref}_${group.subnet_ref}" => group
  })

  default_network_tuple = {
    app_security_group_id = null
    address_spaces        = null
    port_ranges           = null
    port_range            = "*"
  }

  no_network_security_group_subnets = [
    "gatewaysubnet",
    "azurebastionsubnet",
    "azurefirewallsubnet"
  ]
}
