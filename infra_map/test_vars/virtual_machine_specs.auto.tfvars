virtual_machine_set_specs = {
  production = {
    vm_count = 3
    sku_size = "Standard_D4ads_v5"

    os_disk = {
      disk_size_gb         = 128
      storage_account_type = "Premium_LRS"
    }
  }

  non_production = {
    vm_count = 3
    sku_size = "Standard_D4ads_v5"

    os_disk = {
      disk_size_gb         = 128
      storage_account_type = "Premium_LRS"
    }
  }

  external = {
    vm_count = 3
    sku_size = "Standard_D4ads_v5"

    os_disk = {
      disk_size_gb         = 128
      storage_account_type = "Premium_LRS"
    }
  }
}
