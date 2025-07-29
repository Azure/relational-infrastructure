virtual_machine_sets = {
  external = {
    name                = "ext"
    image_name          = "default_windows"
    key_vault_name      = "shared"
    location_name       = "shared"
    resource_group_name = "shared"
    subscription_name   = "shared"
    os_type             = "Windows"

    tags = {
      app = "external"
    }

    network_interfaces = {
      main = {
        network_name = "external"
        subnet_name  = "default"
      }
    }
  }

  production = {
    name                = "prd"
    image_name          = "default_windows"
    key_vault_name      = "shared"
    location_name       = "shared"
    resource_group_name = "shared"
    subscription_name   = "shared"
    os_type             = "Windows"

    tags = {
      app = "production"
    }

    network_interfaces = {
      main = {
        network_name = "production"
        subnet_name  = "production"
      }
    }
  }

  non_production = {
    name                = "npd"
    image_name          = "default_windows"
    key_vault_name      = "shared"
    location_name       = "shared"
    resource_group_name = "shared"
    subscription_name   = "shared"
    os_type             = "Windows"

    tags = {
      app = "production"
    }

    network_interfaces = {
      main = {
        network_name = "non_production"
        subnet_name  = "non_production"
      }
    }
  }
}
