locals {
  allow_in_security_rules = {
    for rule_name, rule in var.network_security_rules : rule_name => {
      access    = "Allow"
      direction = "Inbound"
      protocol  = rule.protocol
      from      = rule.allow.in.from
      to        = rule.allow.in.to
    } if try(rule.allow.in != null, false)
  }

  allow_out_security_rules = {
    for rule_name, rule in var.network_security_rules : rule_name => {
      access    = "Allow"
      direction = "Outbound"
      protocol  = rule.protocol
      from      = rule.allow.out.from
      to        = rule.allow.out.to
    } if try(rule.allow.out != null, false)
  }

  deny_in_security_rules = {
    for rule_name, rule in var.network_security_rules : rule_name => {
      access    = "Deny"
      direction = "Inbound"
      protocol  = rule.protocol
      from      = rule.deny.in.from
      to        = rule.deny.in.to
    } if try(rule.deny.in != null, false)
  }

  deny_out_security_rules = {
    for rule_name, rule in var.network_security_rules : rule_name => {
      access    = "Deny"
      direction = "Outbound"
      protocol  = rule.protocol
      from      = rule.deny.out.from
      to        = rule.deny.out.to
    } if try(rule.deny.out != null, false)
  }

  security_rule_port_ranges = {
    for rule_name, rule in var.network_security_rules : rule_name => (
      rule.port_range != null
      ? [rule.port_range]
      : (
        length(rule.port_ranges) > 0
        ? rule.port_ranges
        : ["*"]
      )
    )
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
          app_security_group_ids = []
          address_spaces         = [rule.to.address_space]
          port_ranges            = local.security_rule_port_ranges[rule_name]
        }
        : (
          rule.to.subnet != null
          ? {
            app_security_group_ids = []
            address_spaces         = [local.network_address_spaces[rule.to.subnet.network_name].subnets[rule.to.subnet.subnet_name].address_space]
            port_ranges            = local.security_rule_port_ranges[rule_name]
          }
          : (
            rule.to.network != null
            ? {
              app_security_group_ids = []
              address_space          = local.network_address_spaces[rule.to.network.network_name].address_spaces
              port_ranges            = local.security_rule_port_ranges[rule_name]
            }
            : {
              app_security_group_ids = [azurerm_application_security_group.application_security_group[rule.to.vm_set.vm_set_name].id]
              address_space          = null
              port_ranges            = local.security_rule_port_ranges[rule_name]
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
          port_range             = "*"
        }
        : (
          rule.from.subnet != null
          ? {
            app_security_group_ids = []
            address_space          = [local.network_address_spaces[rule.from.subnet.network_name].subnets[rule.from.subnet.subnet_name].address_space]
            port_range             = "*"
          }
          : (
            rule.from.network != null
            ? {
              app_security_group_ids = []
              address_space          = local.network_address_spaces[rule.from.network.network_name].address_spaces
              port_range             = "*"
            }
            : {
              app_security_group_ids = [azurerm_application_security_group.application_security_group[rule.from.vm_set.vm_setname].id]
              address_space          = null
              port_range             = "*"
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
      destination_port_ranges                    = local.security_rule_port_ranges[rule_name]
      source_address_prefixes                    = local.security_rule_sources[rule_name].address_spaces
      source_application_security_group_ids      = local.security_rule_sources[rule_name].app_security_group_ids
      source_port_ranges                         = ["*"]
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
              priority = (rule_index * 10)
              config   = local.security_rule_config[rule_name]
            }
          }

        } if !contains(local.no_network_security_group_subnets, lower(subnet.name))
      ] if network != null
    ]) : "${group.network_ref}_${group.subnet_ref}" => group
  })

  default_network_tuple = {
    asg_ids        = []
    address_spaces = ["*"]
    port_range     = "*"
  }

  no_network_security_group_subnets = [
    "gatewaysubnet",
    "azurebastionsubnet",
    "azurefirewallsubnet"
  ]
}
