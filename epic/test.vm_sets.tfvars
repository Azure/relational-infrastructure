workloads = {
  primary = {
    client = {
      arr = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      bca_pc = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      bca_web = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      care_everywhere = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      care_everywhere_arr = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      digital_signing = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      epiccare_link = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      hyperspace_web = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      interconnect = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      mpsql = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }

        data_disks = {
          data = { lun = 0 }
          logs = { lun = 1 }
        }
      }
      system_pulse = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      web_blob = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      kuiper = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      eps = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      kuiper = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      sts = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      citrix_cc = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      willow = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      image_exchange = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
    }
    cogito = {
      clarity_db = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      caboodle_db = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      cubes = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      slicer_dicer = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      clarity_console = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      bi_restful = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
    }
    odb = {
      odb = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      rpt = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
    }
  }
  alt = {
    client = {
      arr = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      bca_pc = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      bca_web = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      care_everywhere = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      care_everywhere_arr = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      digital_signing = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      epiccare_link = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      hyperspace_web = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      interconnect = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      mpsql = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }

        data_disks = {
          data = { lun = 0 }
          logs = { lun = 1 }
        }
      }
      system_pulse = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      web_blob = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      kuiper = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      eps = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      kuiper = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      sts = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      citrix_cc = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      willow = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
      image_exchange = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
    }
    odb = {
      odb = {
        image = {
          reference = {
            offer     = "WindowsServer"
            publisher = "MicrosoftWindowsServer"
            sku       = "2019-Datacenter"
            version   = "latest"
          }
        }
      }
    }
  }
}
