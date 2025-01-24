workload_specs = {
  primary = {
    client = {
      arr = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      bca_pc = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      bca_web = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      care_everywhere = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      care_everywhere_arr = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      digital_signing = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      epiccare_link = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      hyperspace_web = {
        vm_count = 10
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      interconnect = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      mpsql = {
        vm_count = 3
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
        data_disks = {
          data = {
            disk_size_gb         = 128
            storage_account_type = "Premium_LRS"
          }
          logs = {
            disk_size_gb         = 128
            storage_account_type = "Premium_LRS"
          }
        }
      }
      system_pulse = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      eps = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      kuiper = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      mychart = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      sts = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      citrix_cc = {
        vm_count = 3
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      willow = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      image_exchange = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      web_blob = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
    }
  }
  alt = {
    client = {
      arr = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      bca_pc = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      bca_web = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      care_everywhere = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      care_everywhere_arr = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      digital_signing = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      epiccare_link = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      hyperspace_web = {
        vm_count = 10
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      interconnect = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      mpsql = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
        data_disks = {
          data = {
            disk_size_gb         = 128
            storage_account_type = "Premium_LRS"
          }
          logs = {
            disk_size_gb         = 128
            storage_account_type = "Premium_LRS"
          }
        }
      }
      system_pulse = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      eps = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      kuiper = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      mychart = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      sts = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      citrix_cc = {
        vm_count = 3
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      willow = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      image_exchange = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
      web_blob = {
        vm_count = 2
        sku_size = "Standard_D2s_v3"
        os_disk = {
          disk_size_gb         = 128
          storage_account_type = "Premium_LRS"
        }
      }
    }
  }
}
