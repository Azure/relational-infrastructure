output "resources" {
  value = {
    load_balancer = var.load_balancer == null ? null : {
      resource_id     = module.load_balancer[0].resource_id
      resource_name   = local.load_balancer_name
      backend_pool_id = module.load_balancer[0].azurerm_lb_backend_address_pool["backend"].id

      # Populated for internal LBs; null for public
      frontend_private_ip_address = try(
        module.load_balancer[0].azurerm_lb.frontend_ip_configuration[0].private_ip_address,
        null
      )

      # Populated for public LBs; null for internal
      frontend_public_ip_address = var.load_balancer.public_frontend != null ? azurerm_public_ip.load_balancer_frontend[0].ip_address : null
      frontend_public_ip_id      = var.load_balancer.public_frontend != null ? azurerm_public_ip.load_balancer_frontend[0].id : null
    }

    virtual_machines = [
      for vm in module.virtual_machines : {
        resource_id   = vm.resource_id
        resource_name = vm.name

        network_interfaces = {
          for nic_name, nic in vm.network_interfaces :
          nic_name => {
            resource_id        = nic.id
            resource_name      = nic.name
            private_ip_address = nic.private_ip_address
          }
        }
      }
    ]
  }
}
