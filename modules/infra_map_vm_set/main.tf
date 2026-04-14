resource "azurerm_public_ip" "load_balancer_frontend" {
  count = (var.load_balancer != null && var.load_balancer.public_frontend != null) ? 1 : 0

  name                    = coalesce(var.load_balancer.public_frontend.public_ip_name, local.load_balancer_public_ip_name)
  location                = var.location
  resource_group_name     = var.resource_group_name
  allocation_method       = "Static"
  sku                     = var.load_balancer.sku
  zones                   = var.load_balancer.public_frontend.public_ip_zones
  idle_timeout_in_minutes = var.load_balancer.public_frontend.idle_timeout_in_minutes
  ddos_protection_mode    = var.load_balancer.public_frontend.ddos_protection_mode
  tags                    = merge(var.resource_tags, var.load_balancer.tags)
}

module "load_balancer" {
  source = "Azure/avm-res-network-loadbalancer/azurerm"
  count  = var.load_balancer != null ? 1 : 0

  name                = local.load_balancer_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.load_balancer.sku
  tags                = merge(var.resource_tags, var.load_balancer.tags)
  enable_telemetry    = false

  frontend_ip_configurations = {
    frontend = {
      name = local.load_balancer_frontend_ip_name

      # Internal frontend fields — null when using public_frontend
      frontend_private_ip_address            = try(var.load_balancer.internal_frontend.private_ip_address, null)
      frontend_private_ip_address_allocation = try(var.load_balancer.internal_frontend, null) != null ? (var.load_balancer.internal_frontend.private_ip_address == null ? "Dynamic" : "Static") : null
      frontend_private_ip_subnet_resource_id = try(var.load_balancer.internal_frontend.subnet_id, null)

      # Public frontend field — null when using internal_frontend
      public_ip_address_resource_id = try(var.load_balancer.public_frontend, null) != null ? azurerm_public_ip.load_balancer_frontend[0].id : null
    }
  }

  backend_address_pools = {
    backend = {
      name = local.load_balancer_backend_pool_name
    }
  }

  lb_probes = {
    health = {
      name                = local.load_balancer_probe_name
      protocol            = var.load_balancer.health_probe.protocol
      port                = var.network_ports[var.load_balancer.health_probe.port_name]
      interval_in_seconds = var.load_balancer.health_probe.interval_in_seconds
      number_of_probes    = var.load_balancer.health_probe.probe_threshold
      request_path        = var.load_balancer.health_probe.request_path
    }
  }

  lb_rules = {
    for rule_name, rule in var.load_balancer.rules : rule_name => {
      name                              = "${local.load_balancer_rule_name_prefix}-${rule_name}"
      frontend_ip_configuration_name    = local.load_balancer_frontend_ip_name
      protocol                          = rule.protocol
      frontend_port                     = var.network_ports[rule.frontend_port_name]
      backend_port                      = var.network_ports[rule.backend_port_name]
      backend_address_pool_object_names = ["backend"]
      probe_object_name                 = "health"
      idle_timeout_in_minutes           = rule.idle_timeout_in_minutes
      enable_floating_ip                = rule.enable_floating_ip
    }
  }

  backend_address_pool_network_interfaces = {
    for i, vm in module.virtual_machines :
    "vm${i}" => {
      backend_address_pool_object_name = "backend"
      ip_configuration_name            = lower("${local.virtual_machine_names[i]}-${var.load_balancer.nic_name}-ipcfg01")
      network_interface_resource_id    = vm.network_interfaces[var.load_balancer.nic_name].id
    }
  }

  depends_on = [module.virtual_machines]
}

module "virtual_machines" {
  source   = "Azure/avm-res-compute-virtualmachine/azurerm"
  for_each = var.virtual_machines
  version  = "0.20.0" # For now; running into a problems with key vault + passwords

  name                                   = local.virtual_machine_names[each.key]
  lock                                   = local.vm_lock
  tags                                   = var.resource_tags
  location                               = var.location
  computer_name                          = local.virtual_machine_computer_names[each.key]
  extensions                             = var.virtual_machine_extensions
  boot_diagnostics                       = var.enable_virtual_machine_boot_diagnostics
  capacity_reservation_group_resource_id = var.virtual_machine_capacity_reservation_group_id
  disk_controller_type                   = var.virtual_machine_disk_controller_type
  data_disk_managed_disks                = local.virtual_machine_data_disks[each.key]
  enable_automatic_updates               = var.virtual_machine_extensions_automatic_updates_enabled
  encryption_at_host_enabled             = false
  os_disk                                = local.virtual_machine_os_disks[each.key]
  os_type                                = var.virtual_machine_os_type
  network_interfaces                     = local.virtual_machine_network_interfaces[each.key]
  shutdown_schedules                     = var.virtual_machine_shutdown_schedule
  resource_group_name                    = var.resource_group_name
  source_image_reference                 = var.virtual_machine_image.reference
  source_image_resource_id               = var.virtual_machine_image.id
  sku_size                               = var.virtual_machine_sku_size
<<<<<<< HEAD:modules/infra_map_vm_set/main.tf
  zone                                   = local.virtual_machine_zones[each.key]
=======
  zone                                   = local.virtual_machine_zones[count.index]
  virtual_machine_scale_set_resource_id  = var.virtual_machine_scale_set_id
>>>>>>> 2c75bbd6d5bd7303c01c5b6f491bc01cdd013185:infra_map_vm_set/main.tf

  managed_identities = {
    system_assigned            = var.virtual_machine_system_assigned_identity_enabled
    user_assigned_resource_ids = var.user_assigned_identity_ids
  }

  generated_secrets_key_vault_secret_config = (
    var.key_vault_configuration == null ? null
    : local.virtual_machine_secret_configs[each.key]
  )

  maintenance_configuration_resource_ids = (
    var.maintenance_configuration == null ? {}
    : { config = module.virtual_machine_maintenance_configuration[0].resource_id }
  )

  bypass_platform_safety_checks_on_user_schedule_enabled = (var.maintenance_configuration != null)
}

resource "azapi_update_resource" "disable_os_disk_public_network_access" {
  for_each  = var.enable_os_disk_public_network_access ? {} : var.virtual_machines
  type      = "Microsoft.Compute/disks@2023-01-02"
  name      = local.virtual_machine_os_disks[each.key].name
  parent_id = var.resource_group_id

  body = {
    properties = {
      networkAccessPolicy = "DenyAll"
    }
  }

  depends_on = [
    module.virtual_machines
  ]
}

module "virtual_machine_maintenance_configuration" {
  count   = var.maintenance_configuration == null ? 0 : 1
  source  = "Azure/avm-res-maintenance-maintenanceconfiguration/azurerm"
  version = "0.1.0"

  location            = var.location
  name                = local.maintenance_configuration_name
  resource_group_name = var.resource_group_name
  scope               = var.maintenance_configuration.scope
  tags                = var.resource_tags
  window              = var.maintenance_configuration.schedule

  extension_properties = {
    InGuestPatchMode = "User"
  }

  install_patches = {
    reboot_setting = "IfRequired"

    linux = {
      classifications_to_include = ["Critical", "Security"]
    }

    windows = {
      classifications_to_include = ["Critical", "Security"]
    }
  }
}
