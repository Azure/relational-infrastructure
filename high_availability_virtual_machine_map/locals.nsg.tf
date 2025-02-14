locals {
  network_security_groups = tomap({
    for group in flatten([
      for network_ref, network in local.networks : [
        for subnet_ref, subnet in network.subnets : {
          location_ref        = network.location_ref
          network_ref         = network_ref
          subnet_ref          = subnet_ref
          subnet_name         = subnet.name
          name                = lower(coalesce(subnet.security_group_name, "${network.name}-${subnet.name}-nsg"))
          resource_group_name = network.resource_group_name
        } if !contains(local.no_network_security_group_subnets, lower(subnet.name))
      ] if network != null
    ]) : "${group.network_ref}_${group.subnet_ref}" => group
  })

  allow_inbound_network_security_rules = tomap({
    for rule in flatten([
      for network_ref, network in local.networks : [
        for subnet_ref, subnet in network.subnets : [
          for inbound_rule_ref, inbound_rule in coalesce(subnet.security_rules, {}) : {
            network_ref        = network_ref
            subnet_ref         = subnet_ref
            rule_ref           = inbound_rule_ref
            security_group_ref = "${network_ref}_${subnet_ref}"
            rule_name          = coalesce(inbound_rule.name, inbound_rule_ref)
            priority           = inbound_rule.priority
            protocol           = inbound_rule.protocol
            direction          = "Inbound"
            access             = "Allow"

            destination = (
              inbound_rule.allow.in.to == null
              ? {
                address_space = "*"
                port_range    = "*"
              }
              : {
                address_space = (
                  inbound_rule.allow.in.to.subnet != null
                  ? local.networks[inbound_rule.allow.in.to.subnet.network_name].subnets[inbound_rule.allow.in.to.subnet.subnet_name].address_space
                  : (
                    inbound_rule.allow.in.to.network != null
                    ? local.networks[inbound_rule.allow.in.to.network.network_name].address_space
                    : coalesce(inbound_rule.allow.in.to.address_space, "*")
                  )
                )
                port_range = coalesce(inbound_rule.allow.in.to.port_range, "*")
              }
            )

            source = (
              inbound_rule.allow.in.from == null
              ? {
                address_space = "*"
                port_range    = "*"
              }
              : {
                address_space = (
                  inbound_rule.allow.in.from.subnet != null
                  ? local.networks[inbound_rule.allow.in.from.subnet.network_name].subnets[inbound_rule.allow.in.from.subnet.subnet_name].address_space
                  : (
                    inbound_rule.allow.in.from.network != null
                    ? local.networks[inbound_rule.allow.in.from.network.network_name].address_space
                    : coalesce(inbound_rule.allow.in.from.address_space, "*")
                  )
                )
                port_range = coalesce(inbound_rule.allow.in.from.port_range, "*")
              }
            )
          } if try(inbound_rule.allow.in != null, false)
        ] if !contains(local.no_network_security_group_subnets, lower(subnet.name))
      ] if network != null
    ]) : "${rule.network_ref}_${rule.subnet_ref}_${rule.rule_ref}" => rule
  })

  allow_outbound_network_security_rules = tomap({
    for rule in flatten([
      for network_ref, network in local.networks : [
        for subnet_ref, subnet in network.subnets : [
          for outbound_rule_ref, outbound_rule in coalesce(subnet.security_rules, {}) : {
            network_ref        = network_ref
            subnet_ref         = subnet_ref
            rule_ref           = outbound_rule_ref
            security_group_ref = "${network_ref}_${subnet_ref}"
            rule_name          = coalesce(outbound_rule.name, outbound_rule_ref)
            priority           = outbound_rule.priority
            protocol           = outbound_rule.protocol
            direction          = "Outbound"
            access             = "Allow"

            destination = (
              outbound_rule.allow.out.to == null
              ? {
                address_space = "*"
                port_range    = "*"
              }
              : {
                address_space = (
                  outbound_rule.allow.out.to.subnet != null
                  ? local.networks[outbound_rule.allow.out.to.subnet.network_name].subnets[outbound_rule.allow.out.to.subnet.subnet_name].address_space
                  : (
                    outbound_rule.allow.out.to.network != null
                    ? local.networks[outbound_rule.allow.out.to.network.network_name].address_space
                    : coalesce(outbound_rule.allow.out.to.address_space, "*")
                  )
                )
                port_range = coalesce(outbound_rule.allow.out.to.port_range, "*")
              }
            )

            source = (
              outbound_rule.allow.out.from == null
              ? {
                address_space = "*"
                port_range    = "*"
              }
              : {
                address_space = (
                  outbound_rule.allow.out.from.subnet != null
                  ? local.networks[outbound_rule.allow.out.from.subnet.network_name].subnets[outbound_rule.allow.out.from.subnet.subnet_name].address_space
                  : (
                    outbound_rule.allow.out.from.network != null
                    ? local.networks[outbound_rule.allow.out.from.network.network_name].address_space
                    : coalesce(outbound_rule.allow.out.from.address_space, "*")
                  )
                )
                port_range = coalesce(outbound_rule.allow.out.from.port_range, "*")
              }
            )
          } if try(outbound_rule.allow.out != null, false)
        ] if !contains(local.no_network_security_group_subnets, lower(subnet.name))
      ] if network != null
    ]) : "${rule.network_ref}_${rule.subnet_ref}_${rule.rule_ref}" => rule
  })

  deny_inbound_network_security_rules = tomap({
    for rule in flatten([
      for network_ref, network in local.networks : [
        for subnet_ref, subnet in network.subnets : [
          for inbound_rule_ref, inbound_rule in coalesce(subnet.security_rules, {}) : {
            network_ref        = network_ref
            subnet_ref         = subnet_ref
            rule_ref           = inbound_rule_ref
            security_group_ref = "${network_ref}_${subnet_ref}"
            rule_name          = coalesce(inbound_rule.name, inbound_rule_ref)
            priority           = inbound_rule.priority
            protocol           = inbound_rule.protocol
            direction          = "Inbound"
            access             = "Deny"

            destination = (
              inbound_rule.deny.in.to == null
              ? {
                address_space = "*"
                port_range    = "*"
              }
              : {
                address_space = (
                  inbound_rule.deny.in.to.subnet != null
                  ? local.networks[inbound_rule.deny.in.to.subnet.network_name].subnets[inbound_rule.deny.in.to.subnet.subnet_name].address_space
                  : (
                    inbound_rule.deny.in.to.network != null
                    ? local.networks[inbound_rule.deny.in.to.network.network_name].address_space
                    : coalesce(inbound_rule.deny.in.to.address_space, "*")
                  )
                )
                port_range = coalesce(inbound_rule.deny.in.to.port_range, "*")
              }
            )

            source = (
              inbound_rule.deny.in.from == null
              ? {
                address_space = "*"
                port_range    = "*"
              }
              : {
                address_space = (
                  inbound_rule.deny.in.from.subnet != null
                  ? local.networks[inbound_rule.deny.in.from.subnet.network_name].subnets[inbound_rule.deny.in.from.subnet.subnet_name].address_space
                  : (
                    inbound_rule.deny.in.from.network != null
                    ? local.networks[inbound_rule.deny.in.from.network.network_name].address_space
                    : coalesce(inbound_rule.deny.in.from.address_space, "*")
                  )
                )
                port_range = coalesce(inbound_rule.deny.in.from.port_range, "*")
              }
            )
          } if try(inbound_rule.deny.in != null, false)
        ] if !contains(local.no_network_security_group_subnets, lower(subnet.name))
      ] if network != null
    ]) : "${rule.network_ref}_${rule.subnet_ref}_${rule.rule_ref}" => rule
  })

  deny_outbound_network_security_rules = tomap({
    for rule in flatten([
      for network_ref, network in local.networks : [
        for subnet_ref, subnet in network.subnets : [
          for outbound_rule_ref, outbound_rule in coalesce(subnet.security_rules, {}) : {
            network_ref        = network_ref
            subnet_ref         = subnet_ref
            rule_ref           = outbound_rule_ref
            security_group_ref = "${network_ref}_${subnet_ref}"
            rule_name          = coalesce(outbound_rule.name, outbound_rule_ref)
            priority           = outbound_rule.priority
            protocol           = outbound_rule.protocol
            direction          = "Outbound"
            access             = "Deny"

            destination = (
              outbound_rule.deny.out.to == null
              ? {
                address_space = "*"
                port_range    = "*"
              }
              : {
                address_space = (
                  outbound_rule.deny.out.to.subnet != null
                  ? local.networks[outbound_rule.deny.out.to.subnet.network_name].subnets[outbound_rule.deny.out.to.subnet.subnet_name].address_space
                  : (
                    outbound_rule.deny.out.to.network != null
                    ? local.networks[outbound_rule.deny.out.to.network.network_name].address_space
                    : coalesce(outbound_rule.deny.out.to.address_space, "*")
                  )
                )
                port_range = coalesce(outbound_rule.deny.out.to.port_range, "*")
              }
            )

            source = (
              outbound_rule.deny.out.from == null
              ? {
                address_space = "*"
                port_range    = "*"
              }
              : {
                address_space = (
                  outbound_rule.deny.out.from.subnet != null
                  ? local.networks[outbound_rule.deny.out.from.subnet.network_name].subnets[outbound_rule.deny.out.from.subnet.subnet_name].address_space
                  : (
                    outbound_rule.deny.out.from.network != null
                    ? local.networks[outbound_rule.deny.out.from.network.network_name].address_space
                    : coalesce(outbound_rule.deny.out.from.address_space, "*")
                  )
                )
                port_range = coalesce(outbound_rule.deny.out.from.port_range, "*")
              }
            )
          } if try(outbound_rule.deny.out != null, false)
        ] if !contains(local.no_network_security_group_subnets, lower(subnet.name))
      ] if network != null
    ]) : "${rule.network_ref}_${rule.subnet_ref}_${rule.rule_ref}" => rule
  })

  no_network_security_group_subnets = [
    "gatewaysubnet",
    "azurebastionsubnet",
    "azurefirewallsubnet"
  ]
}
