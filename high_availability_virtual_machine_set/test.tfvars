# terraform.tfvars

# General settings
resource_prefix         = "test01"
location                = "canadacentral"
resource_group_name     = "test01"
virtualmachine_count    = 10
virtualmachine_sku_size = "Standard_DS3_v2"

resource_tags = {
  "epic-app" = "hsw"
  "epic-env" = "production"
}

# OS disk configuration
virtualmachine_os_disk = {
  caching              = "ReadWrite"
  storage_account_type = "Premium_LRS"
  disk_size_gb         = 128
}

# Data disks configuration
virtualmachine_data_disks = {
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
virtualmachine_network_interfaces = {
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
virtualmachine_spread_evenly_across_zones = [
  "1",
  "2",
  "3"
]

virtualmachine_os_type = "Windows"

virtualmachine_image_reference = {
  publisher = "MicrosoftWindowsServer"
  offer     = "WindowsServer"
  sku       = "2022-datacenter-g2"
  version   = "latest"
}
