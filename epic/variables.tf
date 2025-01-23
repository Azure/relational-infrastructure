variable "deployment_prefix" {
  type = string
}

variable "environment_name" {
  type = string
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
        address_space = string
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
        address_space = string
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
        address_space = string
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
        address_space = string
        subnets = object({
          hyperspace = object({
            address_space = string
          })
        })
      })
      hyperspace_web = object({
        address_space = string
        subnets = object({
          hyperspace_web = object({
            address_space = string
          })
        })
      })
    })
    primary = object({
      dmz = object({
        address_space = string
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
        address_space = string
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
        address_space = string
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
        address_space = string
        subnets = object({
          hyperspace = object({
            address_space = string
          })
        })
      })
      hyperspace_web = object({
        address_space = string
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

        }), null)
        odb_ecp_app = optional(object({

        }), null)
        odb_ecp_util = optional(object({

        }), null)
        rpt = optional(object({

        }), null)
        rpt_ecp_util = optional(object({

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

        }), null)
        bca_pc = optional(object({

        }), null)
        bca_web = optional(object({

        }), null)
        care_everywhere = optional(object({

        }), null)
        care_everywhere_arr = optional(object({

        }), null)
        digital_signing = optional(object({

        }), null)
        epiccare_link = optional(object({

        }), null)
        hyperspace_web = optional(object({

        }), null)
        interconnect = optional(object({

        }), null)
        mpsql = optional(object({

        }), null)
        system_pulse = optional(object({

        }), null)
        web_blob = optional(object({

        }), null)
        eps = optional(object({

        }), null)
        kuiper = optional(object({

        }), null)
        mychart = optional(object({

        }), null)
        sts = optional(object({

        }), null)
        citrix_cc = optional(object({

        }), null)
        willow = optional(object({

        }), null)
        image_exchange = optional(object({

        }), null)
      }), null)
      cogito = optional(object({
        caboodle_db = optional(object({

        }), null)
        clarity_db = optional(object({

        }), null)
        caboodle_console = optional(object({

        }), null)
        clarity_console = optional(object({

        }), null)
        caboodle_etl = optional(object({

        }), null)
        slicer_dicer = optional(object({

        }), null)
        bi_restful = optional(object({

        }), null)
        cubes = optional(object({

        }), null)
      }), null)
      odb = optional(object({
        odb = optional(object({

        }), null)
        odb_ecp_app = optional(object({

        }), null)
        odb_ecp_util = optional(object({

        }), null)
      }), null)
    }), null)
    primary = object({
      client = optional(object({
        arr = optional(object({

        }), null)
        bca_pc = optional(object({

        }), null)
        bca_web = optional(object({

        }), null)
        care_everywhere = optional(object({

        }), null)
        care_everywhere_arr = optional(object({

        }), null)
        digital_signing = optional(object({

        }), null)
        epiccare_link = optional(object({

        }), null)
        hyperspace_web = optional(object({

        }), null)
        interconnect = optional(object({

        }), null)
        mpsql = optional(object({

        }), null)
        system_pulse = optional(object({

        }), null)
        web_blob = optional(object({

        }), null)
        eps = optional(object({

        }), null)
        kuiper = optional(object({

        }), null)
        mychart = optional(object({

        }), null)
        sts = optional(object({

        }), null)
        citrix_cc = optional(object({

        }), null)
        willow = optional(object({

        }), null)
        image_exchange = optional(object({

        }), null)
      }), null)
      cogito = optional(object({
        caboodle_db = optional(object({

        }), null)
        clarity_db = optional(object({

        }), null)
        caboodle_console = optional(object({

        }), null)
        clarity_console = optional(object({

        }), null)
        caboodle_etl = optional(object({

        }), null)
        slicer_dicer = optional(object({

        }), null)
        bi_restful = optional(object({

        }), null)
        cubes = optional(object({

        }), null)
      }), null)
      odb = optional(object({
        odb = optional(object({

        }), null)
        odb_ecp_app = optional(object({

        }), null)
        odb_ecp_util = optional(object({

        }), null)
        rpt = optional(object({

        }), null)
        rpt_ecp_util = optional(object({

        }), null)
      }), null)
    })
  })
}

variable "workload_zone_distribution" {
  type = object({
    alt = optional(object({
      client = optional(object({
        arr = optional(object({

        }), null)
        bca_pc = optional(object({

        }), null)
        bca_web = optional(object({

        }), null)
        care_everywhere = optional(object({

        }), null)
        care_everywhere_arr = optional(object({

        }), null)
        digital_signing = optional(object({

        }), null)
        epiccare_link = optional(object({

        }), null)
        hyperspace_web = optional(object({

        }), null)
        interconnect = optional(object({

        }), null)
        mpsql = optional(object({

        }), null)
        system_pulse = optional(object({

        }), null)
        web_blob = optional(object({

        }), null)
        eps = optional(object({

        }), null)
        kuiper = optional(object({

        }), null)
        mychart = optional(object({

        }), null)
        sts = optional(object({

        }), null)
        citrix_cc = optional(object({

        }), null)
        willow = optional(object({

        }), null)
        image_exchange = optional(object({

        }), null)
      }), null)
      cogito = optional(object({
        caboodle_db = optional(object({

        }), null)
        clarity_db = optional(object({

        }), null)
        caboodle_console = optional(object({

        }), null)
        clarity_console = optional(object({

        }), null)
        caboodle_etl = optional(object({

        }), null)
        slicer_dicer = optional(object({

        }), null)
        bi_restful = optional(object({

        }), null)
        cubes = optional(object({

        }), null)
      }), null)
      odb = optional(object({
        odb = optional(object({

        }), null)
        odb_ecp_app = optional(object({

        }), null)
        odb_ecp_util = optional(object({

        }), null)
      }), null)
    }), null)
    primary = optional(object({
      client = optional(object({
        arr = optional(object({

        }), null)
        bca_pc = optional(object({

        }), null)
        bca_web = optional(object({

        }), null)
        care_everywhere = optional(object({

        }), null)
        care_everywhere_arr = optional(object({

        }), null)
        digital_signing = optional(object({

        }), null)
        epiccare_link = optional(object({

        }), null)
        hyperspace_web = optional(object({

        }), null)
        interconnect = optional(object({

        }), null)
        mpsql = optional(object({

        }), null)
        system_pulse = optional(object({

        }), null)
        web_blob = optional(object({

        }), null)
        eps = optional(object({

        }), null)
        kuiper = optional(object({

        }), null)
        mychart = optional(object({

        }), null)
        sts = optional(object({

        }), null)
        citrix_cc = optional(object({

        }), null)
        willow = optional(object({

        }), null)
        image_exchange = optional(object({

        }), null)
      }), null)
      cogito = optional(object({
        caboodle_db = optional(object({

        }), null)
        clarity_db = optional(object({

        }), null)
        caboodle_console = optional(object({

        }), null)
        clarity_console = optional(object({

        }), null)
        caboodle_etl = optional(object({

        }), null)
        slicer_dicer = optional(object({

        }), null)
        bi_restful = optional(object({

        }), null)
        cubes = optional(object({

        }), null)
      }), null)
      odb = optional(object({
        odb = optional(object({

        }), null)
        odb_ecp_app = optional(object({

        }), null)
        odb_ecp_util = optional(object({

        }), null)
        rpt = optional(object({

        }), null)
        rpt_ecp_util = optional(object({

        }), null)
      }), null)
    }), null)
  })
}
