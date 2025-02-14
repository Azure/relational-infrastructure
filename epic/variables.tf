variable "deployment_prefix" {
  type = string
}

variable "ddos_protection_plan_name" {
  type     = string
  default  = null
  nullable = true
}

variable "environment_name" {
  type = string
}

variable "include_label_tags" {
  type    = bool
  default = true
}

variable "enable_automatic_updates" {
  type    = bool
  default = false
}

variable "locations" {
  type = object({
    alt     = optional(string, null),
    primary = string
  })
}

variable "networks" {
  type = object({
    alt = object({
      dmz = object({
        address_space          = string
        dns_ip_addresses       = optional(set(string), null)
        enable_ddos_protection = optional(bool, false)
        subnets = object({
          firewall = object({
            address_space = string
          })
          production = object({
            address_space = string
          })
          non_production = object({
            address_space = string
          })
        })
      })
      shared_infra = object({
        address_space          = string
        dns_ip_addresses       = optional(set(string), null)
        enable_ddos_protection = optional(bool, false)
        subnets = object({
          gateway = object({
            address_space = string
          })
          management = object({
            address_space = string
          })
        })
      })
      main = object({
        address_space          = string
        dns_ip_addresses       = optional(set(string), null)
        enable_ddos_protection = optional(bool, false)
        subnets = object({
          cogito = object({
            address_space = string
          })
          odb = object({
            address_space = string
          })
          wss = object({
            address_space = string
          })
        })
      })
      hyperspace = object({
        address_space          = string
        dns_ip_addresses       = optional(set(string), null)
        enable_ddos_protection = optional(bool, false)
        subnets = object({
          hyperspace = object({
            address_space = string
          })
        })
      })
      hyperspace_web = object({
        address_space          = string
        dns_ip_addresses       = optional(set(string), null)
        enable_ddos_protection = optional(bool, false)
        subnets = object({
          hyperspace_web = object({
            address_space = string
          })
        })
      })
    })
    primary = object({
      dmz = object({
        address_space          = string
        dns_ip_addresses       = optional(set(string), null)
        enable_ddos_protection = optional(bool, false)
        subnets = object({
          firewall = object({
            address_space = string
          })
          production = object({
            address_space = string
          })
          non_production = object({
            address_space = string
          })
        })
      })
      shared_infra = object({
        address_space          = string
        dns_ip_addresses       = optional(set(string), null)
        enable_ddos_protection = optional(bool, false)
        subnets = object({
          gateway = object({
            address_space = string
          })
          management = object({
            address_space = string
          })
        })
      })
      main = object({
        address_space          = string
        dns_ip_addresses       = optional(set(string), null)
        enable_ddos_protection = optional(bool, false)
        subnets = object({
          cogito = object({
            address_space = string
          })
          odb = object({
            address_space = string
          })
          wss = object({
            address_space = string
          })
        })
      })
      hyperspace = object({
        address_space          = string
        dns_ip_addresses       = optional(set(string), null)
        enable_ddos_protection = optional(bool, false)
        subnets = object({
          hyperspace = object({
            address_space = string
          })
        })
      })
      hyperspace_web = object({
        address_space          = string
        dns_ip_addresses       = optional(set(string), null)
        enable_ddos_protection = optional(bool, false)
        subnets = object({
          hyperspace_web = object({
            address_space = string
          })
        })
      })
    })
  })
}

variable "workloads" {
  type = object({
    alt = optional(object({
      client = optional(object({
        arr = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        bca_pc = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        bca_web = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        care_everywhere = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        care_everywhere_arr = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        digital_signing = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        epiccare_link = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        hyperspace_web = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        interconnect = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        mpsql = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        system_pulse = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        web_blob = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        eps = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        kuiper = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        mychart = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        sts = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        citrix_cc = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        willow = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        image_exchange = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
      }), null)
      cogito = optional(object({
        caboodle_db = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        clarity_db = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        caboodle_console = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        clarity_console = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        caboodle_etl = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        slicer_dicer = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        bi_restful = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        cubes = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
      }), null)
      odb = optional(object({
        odb = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        odb_ecp_app = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        odb_ecp_util = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
      }), null)
    }), null)
    primary = object({
      client = optional(object({
        arr = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        bca_pc = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        bca_web = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        care_everywhere = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        care_everywhere_arr = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        digital_signing = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        epiccare_link = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        hyperspace_web = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        interconnect = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        mpsql = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        system_pulse = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        web_blob = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        eps = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        kuiper = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        mychart = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        sts = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        citrix_cc = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        willow = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        image_exchange = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
      }), null)
      cogito = optional(object({
        caboodle_db = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        clarity_db = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        caboodle_console = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        clarity_console = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        caboodle_etl = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        slicer_dicer = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        bi_restful = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        cubes = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
      }), null)
      odb = optional(object({
        odb = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        odb_ecp_app = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        odb_ecp_util = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        rpt = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
        rpt_ecp_util = optional(object({
          capacity_reservation_group_id = optional(string, null)

          image = object({
            id = optional(string, null) # or...
            reference = optional(object({
              offer     = string
              publisher = string
              sku       = string
              version   = string
            }), null)
          })

          data_disks = optional(map(object({
            lun     = number
            caching = optional(string, "ReadWrite")
            image = optional(object({
              copy = optional(object({
                resource_id = string
              }), null) # or...
              import = optional(object({
                uri    = string
                secure = optional(bool, true)
              }), null) # or...
              platform = optional(object({
                image_reference_id = string
              }), null) # or...
              restore = optional(object({
                resource_id = string
              }), null)
            }), null)
          })), {})
        }), null)
      }), null)
    })
  })
}

variable "workload_specs" {
  type = object({
    alt = optional(object({
      client = optional(object({
        arr = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        bca_pc = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        bca_web = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        care_everywhere = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        care_everywhere_arr = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        digital_signing = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        epiccare_link = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        hyperspace_web = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        interconnect = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        mpsql = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        system_pulse = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        web_blob = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        eps = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        kuiper = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        mychart = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        sts = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        citrix_cc = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        willow = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        image_exchange = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
      }), null)
      cogito = optional(object({
        caboodle_db = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        clarity_db = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        caboodle_console = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        clarity_console = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        caboodle_etl = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        slicer_dicer = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        bi_restful = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        cubes = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
      }), null)
      odb = optional(object({
        odb = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        odb_ecp_app = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        odb_ecp_util = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
      }), null)
    }), null)
    primary = object({
      client = optional(object({
        arr = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        bca_pc = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        bca_web = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        care_everywhere = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        care_everywhere_arr = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        digital_signing = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        epiccare_link = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        hyperspace_web = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        interconnect = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        mpsql = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        system_pulse = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        web_blob = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        eps = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        kuiper = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        mychart = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        sts = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        citrix_cc = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        willow = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        image_exchange = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
      }), null)
      cogito = optional(object({
        caboodle_db = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        clarity_db = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        caboodle_console = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        clarity_console = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        caboodle_etl = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        slicer_dicer = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        bi_restful = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        cubes = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
      }), null)
      odb = optional(object({
        odb = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        odb_ecp_app = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        odb_ecp_util = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        rpt = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
        rpt_ecp_util = optional(object({
          vm_count = optional(number, 2)
          sku_size = string
          data_disks = optional(map(object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })), {})
          os_disk = object({
            disk_size_gb         = number
            storage_account_type = optional(string, "PremiumV2_LRS")
          })
        }), null)
      }), null)
    })
  })
}

variable "workload_zone_distribution" {
  default  = null
  nullable = true

  type = object({
    alt = optional(object({
      client = optional(object({
        arr = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        bca_pc = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        bca_web = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        care_everywhere = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        care_everywhere_arr = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        digital_signing = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        epiccare_link = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        hyperspace_web = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        interconnect = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        mpsql = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        system_pulse = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        web_blob = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        eps = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        kuiper = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        mychart = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        sts = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        citrix_cc = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        willow = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        image_exchange = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
      }), null)
      cogito = optional(object({
        caboodle_db = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        clarity_db = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        caboodle_console = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        clarity_console = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        caboodle_etl = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        slicer_dicer = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        bi_restful = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        cubes = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
      }), null)
      odb = optional(object({
        odb = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        odb_ecp_app = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        odb_ecp_util = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
      }), null)
    }), null)
    primary = optional(object({
      client = optional(object({
        arr = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        bca_pc = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        bca_web = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        care_everywhere = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        care_everywhere_arr = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        digital_signing = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        epiccare_link = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        hyperspace_web = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        interconnect = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        mpsql = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        system_pulse = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        web_blob = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        eps = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        kuiper = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        mychart = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        sts = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        citrix_cc = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        willow = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        image_exchange = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
      }), null)
      cogito = optional(object({
        caboodle_db = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        clarity_db = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        caboodle_console = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        clarity_console = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        caboodle_etl = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        slicer_dicer = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        bi_restful = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        cubes = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
      }), null)
      odb = optional(object({
        odb = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        odb_ecp_app = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        odb_ecp_util = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        rpt = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
        rpt_ecp_util = optional(object({
          custom = optional(map(number), null)
          even   = optional(list(string), null)
        }), null)
      }), null)
    }), null)
  })
}
