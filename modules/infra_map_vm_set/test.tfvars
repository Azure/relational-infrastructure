# terraform.tfvars

# General settings
resource_prefix         = "test01"
location                = "canadacentral"
resource_group_name     = "test01"
resource_group_id       = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test01"

virtual_machines = {
  vm01 = { sequence_number = 1 }
  vm02 = { sequence_number = 2 }
  vm03 = { sequence_number = 3 }
  vm04 = { sequence_number = 4 }
  vm05 = { sequence_number = 5 }
  vm06 = { sequence_number = 6 }
  vm07 = { sequence_number = 7 }
  vm08 = { sequence_number = 8 }
  vm09 = { sequence_number = 9 }
  vm10 = { sequence_number = 10 }
}

virtual_machine_sku_size = "Standard_DS3_v2"

resource_tags = {
  "epic-app" = "hsw"
  "epic-env" = "production"
}

# OS disk configuration
virtual_machine_os_disk = {
  caching              = "ReadWrite"
  storage_account_type = "Premium_LRS"
  disk_size_gb         = 128
}

# Data disks configuration
virtual_machine_data_disks = {
  disk1 = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    lun                  = 0
    disk_size_gb         = 128
  }
  disk2 = {
    caching              = "ReadOnly"
    storage_account_type = "Standard_LRS"
    lun                  = 1
    disk_size_gb         = 256
  }
}

# Network interfaces configuration
virtual_machine_network_interfaces = {
  general = {
    subnet_id             = "/subscriptions/00363a64-55c1-4807-92a4-7dfe011d5222/resourceGroups/test01/providers/Microsoft.Network/virtualNetworks/test01vnet/subnets/default"
    private_ip_allocation = "Dynamic"
  }
  cluster = {
    subnet_id             = "/subscriptions/00363a64-55c1-4807-92a4-7dfe011d5222/resourceGroups/test01/providers/Microsoft.Network/virtualNetworks/test01vnet/subnets/alt"
    private_ip_allocation = "Dynamic"
  }
}

# Spread across zones configuration
virtual_machine_zone_distribution = {
  even = ["1", "2", "3"]
}

virtual_machine_os_type = "Windows"

virtual_machine_image = {
  reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-g2"
    version   = "latest"
  }
}
