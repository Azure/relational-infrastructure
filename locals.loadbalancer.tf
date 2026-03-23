locals {
  # =============================================================================
  # Load Balancer Names
  # =============================================================================
  load_balancer_names = {
    for lb_key, lb in var.load_balancers
    : lb_key => (
      replace(
        lb.name == null
        ? "${var.deployment_prefix}-${lb_key}-lb"
        : "${var.deployment_prefix}-${lb.name}",
        "_", "-"
      )
    )
  }

  # =============================================================================
  # Load Balancer Tags
  # =============================================================================
  load_balancer_tags = {
    for lb_key, lb in var.load_balancers :
    lb_key => merge(
      var.tags,
      lb.tags,
      var.include_label_tags ? {
        "load_balancer_label"  = lb_key,
        "load_balancer_type"   = lb.type,
        "location_label"       = lb.location_key_reference,
        "resource_group_label" = lb.resource_group_key_reference
      } : {}
    )
  }

  # =============================================================================
  # Load Balancer Locks
  # =============================================================================
  load_balancer_locked = {
    for lb_key, lb in var.load_balancers :
    lb_key => (
      (length(lb.lock_groups_key_reference) > 0) &&
      (length([
        for group in lb.lock_groups_key_reference :
        group if !contains(keys(local.unlocked_groups), group)
      ]) > 0)
    )
  }

  load_balancer_locks = {
    for lb_key, lb in var.load_balancers :
    lb_key => (
      length([
        for group in lb.lock_groups_key_reference :
        group if contains(keys(local.locked_groups), group)
      ]) > 0
      ? (
        anytrue([
          for group in lb.lock_groups_key_reference :
          contains(keys(local.locked_groups), group) && try(local.locked_groups[group].read_only, false)
        ])
        ? { kind = local.lock_modes.read_only, name = "${local.load_balancer_names[lb_key]}-lock" }
        : { kind = local.lock_modes.no_delete, name = "${local.load_balancer_names[lb_key]}-lock" }
      )
      : null
    )
  }

  # =============================================================================
  # DDoS Protection Configuration
  # Determines if DDoS protection mode should be auto-enabled for public IPs
  # =============================================================================
  has_ddos_protection_plan = anytrue(values(var.virtual_networks)[*].enable_ddos_protection)

  # =============================================================================
  # Load Balancer Frontend IP Configurations
  # Uses AVM module's built-in public IP creation for external load balancers
  # =============================================================================
  load_balancer_frontend_configs = {
    for lb_key, lb in var.load_balancers :
    lb_key => {
      for fe_key, fe in lb.frontend_ip_configurations :
      fe_key => {
        name = coalesce(fe.name, "${local.load_balancer_names[lb_key]}-${fe_key}-fe")

        # Internal LB configuration
        frontend_private_ip_subnet_resource_id = (
          lb.type == "internal"
          ? local.network_resource_ids[fe.network_key_reference].subnets[fe.subnet_key_reference].resource_id
          : null
        )
        frontend_private_ip_address            = lb.type == "internal" ? fe.private_ip_address : null
        frontend_private_ip_address_allocation = lb.type == "internal" ? fe.private_ip_allocation : null
        zones                                  = fe.zones

        # External LB configuration - use AVM module's public IP creation
        create_public_ip_address        = lb.type == "external"
        public_ip_address_resource_name = lb.type == "external" ? "${local.load_balancer_names[lb_key]}-${fe_key}-pip" : null

        # Public IP inherits tags from the load balancer
        inherit_tags = true
      }
    }
  }

  # Get public IP configuration for each load balancer (uses first frontend's reference)
  load_balancer_public_ip_configs = {
    for lb_key, lb in var.load_balancers :
    lb_key => (
      lb.type == "external"
      ? var.public_ip_configurations[
          [for fe in values(lb.frontend_ip_configurations) : fe.public_ip_key_reference if fe.public_ip_key_reference != null][0]
        ]
      : null
    )
  }

  # =============================================================================
  # Load Balancer Backend Pools
  # =============================================================================
  load_balancer_backend_pools = {
    for lb_key, lb in var.load_balancers :
    lb_key => {
      for pool_key, pool in lb.backend_pools :
      pool_key => {
        name = coalesce(pool.name, "${local.load_balancer_names[lb_key]}-${pool_key}-bepool")
      }
    }
  }

  # Flattened backend pool references for VM network interfaces
  backend_pool_resource_ids = {
    for item in flatten([
      for lb_key, lb in var.load_balancers : [
        for pool_key, pool in lb.backend_pools : {
          key    = "${lb_key}/${pool_key}"
          lb_key = lb_key
          pool_key = pool_key
        }
      ]
    ]) : item.key => item
  }

  # =============================================================================
  # Load Balancer Health Probes
  # =============================================================================
  load_balancer_health_probes = {
    for lb_key, lb in var.load_balancers :
    lb_key => {
      for rule_key, rule in var.load_balancer_rules :
      rule_key => {  # Use rule_key as the key so lb_rules can reference it
        name                            = "${local.load_balancer_names[lb_key]}-${rule_key}-probe"
        protocol                        = var.health_probes[rule.health_probe_key_reference].protocol
        port                            = tonumber(var.network_ports[var.health_probes[rule.health_probe_key_reference].port_key])
        request_path                    = var.health_probes[rule.health_probe_key_reference].request_path
        interval_in_seconds             = var.health_probes[rule.health_probe_key_reference].interval_in_seconds
        number_of_probes_before_removal = var.health_probes[rule.health_probe_key_reference].number_of_probes
        probe_threshold                 = var.health_probes[rule.health_probe_key_reference].probe_threshold
      } if rule.load_balancer_key_reference == lb_key
    }
  }

  # =============================================================================
  # Load Balancer Rules
  # =============================================================================
  load_balancer_rules_by_lb = {
    for lb_key, lb in var.load_balancers :
    lb_key => {
      for rule_key, rule in var.load_balancer_rules :
      rule_key => {
        name                            = coalesce(rule.name, "${local.load_balancer_names[lb_key]}-${rule_key}-rule")
        protocol                        = rule.protocol
        frontend_port                   = tonumber(var.network_ports[rule.frontend_port_key])
        backend_port                    = tonumber(var.network_ports[rule.backend_port_key])
        frontend_ip_configuration_name  = local.load_balancer_frontend_configs[lb_key][rule.frontend_key_reference].name
        backend_address_pool_object_names = [rule.backend_pool_key_reference]  # Use key, not name
        probe_object_name               = rule_key  # Use rule_key as the probe key in lb_probes
        enable_floating_ip              = rule.enable_floating_ip
        enable_tcp_reset                = rule.enable_tcp_reset
        idle_timeout_in_minutes         = rule.idle_timeout_in_minutes
        load_distribution               = rule.load_distribution
        disable_outbound_snat           = rule.disable_outbound_snat
      } if rule.load_balancer_key_reference == lb_key
    }
  }

  # =============================================================================
  # Load Balancer NAT Rules
  # =============================================================================
  load_balancer_nat_rules_by_lb = {
    for lb_key, lb in var.load_balancers :
    lb_key => {
      for rule_key, rule in var.load_balancer_nat_rules :
      rule_key => {
        name                           = coalesce(rule.name, "${local.load_balancer_names[lb_key]}-${rule_key}-nat")
        protocol                       = rule.protocol
        frontend_port                  = rule.frontend_port_key != null ? tonumber(var.network_ports[rule.frontend_port_key]) : null
        frontend_port_start            = rule.frontend_port_start_key != null ? tonumber(var.network_ports[rule.frontend_port_start_key]) : null
        frontend_port_end              = rule.frontend_port_end_key != null ? tonumber(var.network_ports[rule.frontend_port_end_key]) : null
        backend_port                   = tonumber(var.network_ports[rule.backend_port_key])
        frontend_ip_configuration_name = local.load_balancer_frontend_configs[lb_key][rule.frontend_key_reference].name
        backend_address_pool_object_name = (
          rule.backend_pool_key_reference != null
          ? local.load_balancer_backend_pools[lb_key][rule.backend_pool_key_reference].name
          : null
        )
        enable_floating_ip      = rule.enable_floating_ip
        enable_tcp_reset        = rule.enable_tcp_reset
        idle_timeout_in_minutes = rule.idle_timeout_in_minutes
      } if rule.load_balancer_key_reference == lb_key
    }
  }

  # =============================================================================
  # Load Balancers to Provision
  # =============================================================================
  load_balancers_to_provision = {
    for lb_key, lb in var.load_balancers :
    lb_key => {
      name                = local.load_balancer_names[lb_key]
      location            = var.locations[lb.location_key_reference]
      resource_group_name = module.resource_groups[lb.resource_group_key_reference].name
      sku                 = lb.sku
      sku_tier            = lb.sku_tier
      tags                = local.load_balancer_tags[lb_key]
      lock                = local.load_balancer_locks[lb_key]
      type                = lb.type

      # Public IP configuration for external load balancers
      # Uses the referenced public_ip_configuration with auto-determined DDoS mode
      # If a DDoS plan exists and user hasn't specified mode, use "Enabled" with the plan ID
      public_ip_address_configuration = (
        lb.type == "external" && local.load_balancer_public_ip_configs[lb_key] != null
        ? {
          allocation_method                = local.load_balancer_public_ip_configs[lb_key].allocation_method
          ddos_protection_mode             = coalesce(
            local.load_balancer_public_ip_configs[lb_key].ddos_protection_mode,
            "Enabled"
          )
          ddos_protection_plan_resource_id = try(
            coalesce(
              local.load_balancer_public_ip_configs[lb_key].ddos_protection_plan_id,
              local.has_ddos_protection_plan ? module.ddos_protection_plan[0].resource_id : null
            ),
            null
          )
          domain_name_label                = local.load_balancer_public_ip_configs[lb_key].domain_name_label
          idle_timeout_in_minutes          = local.load_balancer_public_ip_configs[lb_key].idle_timeout_in_minutes
          sku                              = local.load_balancer_public_ip_configs[lb_key].sku
          sku_tier                         = local.load_balancer_public_ip_configs[lb_key].sku_tier
        }
        : {}
      )

      # Frontend IP configurations - uses AVM module's built-in public IP creation
      frontend_ip_configurations = local.load_balancer_frontend_configs[lb_key]

      # Backend pools
      backend_address_pools = local.load_balancer_backend_pools[lb_key]

      # Health probes
      lb_probes = local.load_balancer_health_probes[lb_key]

      # Load balancer rules
      lb_rules = local.load_balancer_rules_by_lb[lb_key]

      # NAT rules
      nat_rules = local.load_balancer_nat_rules_by_lb[lb_key]
    }
  }
}
