virtual_machine_sets = {
  arr = {
    name                = "arr"
    image_name          = "default_windows"
    key_vault_name      = "production"
    location_name       = "production"
    resource_group_name = "arr"
    subscription_name   = "production"
    os_type             = "Windows"

    tags = {
      epic-app = "arr"
    }

    network_interfaces = {
      main = {
        network_name = "shared_dmz"
        subnet_name  = "production"
      }
    }
  }

  care_everywhere = {
    name                = "cev"
    image_name          = "default_windows"
    key_vault_name      = "production"
    location_name       = "production"
    resource_group_name = "care_everywhere"
    subscription_name   = "production"
    os_type             = "Windows"

    tags = {
      epic-app = "careeverywhere"
    }

    network_interfaces = {
      main = {
        network_name = "shared_dmz"
        subnet_name  = "production"
      }
    }
  }

  care_everywhere_arr = {
    name                = "car"
    image_name          = "default_windows"
    key_vault_name      = "production"
    location_name       = "production"
    resource_group_name = "care_everywhere"
    subscription_name   = "production"
    os_type             = "Windows"

    tags = {
      epic-app = "careeverywherearr"
    }

    network_interfaces = {
      main = {
        network_name = "shared_dmz"
        subnet_name  = "production"
      }
    }
  }

  digital_signing = {
    name                = "dss"
    image_name          = "default_windows"
    key_vault_name      = "production"
    location_name       = "production"
    resource_group_name = "digital_signing"
    subscription_name   = "production"
    os_type             = "Windows"

    tags = {
      epic-app = "dss"
    }

    network_interfaces = {
      main = {
        network_name = "production"
        subnet_name  = "wss"
      }
    }
  }

  epiccare_link = {
    name                = "ecl"
    image_name          = "default_windows"
    key_vault_name      = "production"
    location_name       = "production"
    resource_group_name = "epiccare_link"
    subscription_name   = "production"
    os_type             = "Windows"

    tags = {
      epic-app = "ecl"
    }

    network_interfaces = {
      main = {
        network_name = "shared_dmz"
        subnet_name  = "production"
      }
    }
  }

  hyperspace_web_internal = {
    name                = "hswint"
    image_name          = "default_windows"
    key_vault_name      = "production"
    location_name       = "production"
    resource_group_name = "hyperspace_web"
    subscription_name   = "production"
    os_type             = "Windows"

    tags = {
      epic-app = "hsw"
    }

    network_interfaces = {
      main = {
        network_name = "production"
        subnet_name  = "hyperspace_web"
      }
    }
  }

  hyperspace_web_external = {
    name                = "hswext"
    image_name          = "default_windows"
    key_vault_name      = "production"
    location_name       = "production"
    resource_group_name = "hyperspace_web"
    subscription_name   = "production"
    os_type             = "Windows"

    tags = {
      epic-app = "hsw"
    }

    network_interfaces = {
      main = {
        network_name = "shared_dmz"
        subnet_name  = "production"
      }
    }
  }

  interconnect_internal = {
    name                = "incint"
    image_name          = "default_windows"
    key_vault_name      = "production"
    location_name       = "production"
    resource_group_name = "interconnect"
    subscription_name   = "production"
    os_type             = "Windows"

    tags = {
      epic-app = "interconnect"
    }

    network_interfaces = {
      main = {
        network_name = "production"
        subnet_name  = "wss"
      }
    }
  }

  interconnect_external = {
    name                = "incext"
    image_name          = "default_windows"
    key_vault_name      = "production"
    location_name       = "production"
    resource_group_name = "interconnect"
    subscription_name   = "production"
    os_type             = "Windows"

    tags = {
      epic-app = "interconnect"
    }

    network_interfaces = {
      main = {
        network_name = "shared_dmz"
        subnet_name  = "production"
      }
    }
  }

  system_pulse = {
    name                = "sps"
    image_name          = "default_windows"
    key_vault_name      = "production"
    location_name       = "production"
    resource_group_name = "system_pulse"
    subscription_name   = "production"
    os_type             = "Windows"

    tags = {
      epic-app = "systempulse"
    }

    network_interfaces = {
      main = {
        network_name = "shared_infra"
        subnet_name  = "management"
      }
    }
  }

  web_blob = {
    name                = "wbs"
    image_name          = "default_windows"
    key_vault_name      = "production"
    location_name       = "production"
    resource_group_name = "web_blob"
    subscription_name   = "production"
    os_type             = "Windows"

    tags = {
      epic-app = "wbs"
    }

    network_interfaces = {
      main = {
        network_name = "production"
        subnet_name  = "wss"
      }
    }
  }

  eps = {
    name                = "eps"
    image_name          = "default_windows"
    key_vault_name      = "production"
    location_name       = "production"
    resource_group_name = "eps"
    subscription_name   = "production"
    os_type             = "Windows"

    tags = {
      epic-app = "eps"
    }

    network_interfaces = {
      main = {
        network_name = "production"
        subnet_name  = "wss"
      }
    }
  }

  kuiper = {
    name                = "kpr"
    image_name          = "default_windows"
    key_vault_name      = "production"
    location_name       = "production"
    resource_group_name = "kuiper"
    subscription_name   = "production"
    os_type             = "Windows"

    tags = {
      epic-app = "kuiper"
    }

    network_interfaces = {
      main = {
        network_name = "shared_infra"
        subnet_name  = "management"
      }
    }
  }

  mpsql = {
    name                = "sql"
    image_name          = "default_windows"
    key_vault_name      = "production"
    location_name       = "production"
    resource_group_name = "mpsql"
    subscription_name   = "production"
    os_type             = "Windows"

    tags = {
      epic-app = "mpsql"
    }

    network_interfaces = {
      main = {
        network_name = "shared_infra"
        subnet_name  = "management"
      }
    }
  }

  mychart = {
    name                = "myc"
    image_name          = "default_windows"
    key_vault_name      = "production"
    location_name       = "production"
    resource_group_name = "mychart"
    subscription_name   = "production"
    os_type             = "Windows"

    tags = {
      epic-app = "mychart"
    }

    network_interfaces = {
      main = {
        network_name = "shared_dmz"
        subnet_name  = "production"
      }
    }
  }

  sts = {
    name                = "sts"
    image_name          = "default_windows"
    key_vault_name      = "production"
    location_name       = "production"
    resource_group_name = "sts"
    subscription_name   = "production"
    os_type             = "Windows"

    tags = {
      epic-app = "sts"
    }

    network_interfaces = {
      main = {
        network_name = "shared_dmz"
        subnet_name  = "production"
      }
    }
  }

  citrix_cc = {
    name                = "ccc"
    image_name          = "default_windows"
    key_vault_name      = "production"
    location_name       = "production"
    resource_group_name = "citrix_cc"
    subscription_name   = "production"
    os_type             = "Windows"

    tags = {
      epic-app = "citrix-cc"
    }

    network_interfaces = {
      main = {
        network_name = "production"
        subnet_name  = "hyperspace"
      }
    }
  }

  willow = {
    name                = "wil"
    image_name          = "default_windows"
    key_vault_name      = "production"
    location_name       = "production"
    resource_group_name = "willow"
    subscription_name   = "production"
    os_type             = "Windows"

    tags = {
      epic-app = "willow"
    }

    network_interfaces = {
      main = {
        network_name = "production"
        subnet_name  = "wss"
      }
    }
  }

  image_exchange = {
    name                = "imx"
    image_name          = "default_windows"
    key_vault_name      = "production"
    location_name       = "production"
    resource_group_name = "image_exchange"
    subscription_name   = "production"
    os_type             = "Windows"

    tags = {
      epic-app = "imageexchange"
    }

    network_interfaces = {
      main = {
        network_name = "shared_dmz"
        subnet_name  = "production"
      }
    }
  }

  odb = {
    name                = "odb"
    image_name          = "default_windows"
    key_vault_name      = "production"
    location_name       = "production"
    resource_group_name = "odb"
    subscription_name   = "production"
    os_type             = "Windows"

    tags = {
      epic-app = "odb"
    }

    network_interfaces = {
      main = {
        network_name = "production"
        subnet_name  = "odb_cogito"
      }
    }
  }

  rpt = {
    name                = "rpt"
    image_name          = "default_windows"
    key_vault_name      = "production"
    location_name       = "production"
    resource_group_name = "odb"
    subscription_name   = "production"
    os_type             = "Windows"

    tags = {
      epic-app = "odb-rpt"
    }

    network_interfaces = {
      main = {
        network_name = "production"
        subnet_name  = "odb_cogito"
      }
    }
  }

  ecp_app = {
    name                = "ecpapp"
    image_name          = "default_windows"
    key_vault_name      = "production"
    location_name       = "production"
    resource_group_name = "odb"
    subscription_name   = "production"
    os_type             = "Windows"

    tags = {
      epic-app = "odb-ecp-app"
    }

    network_interfaces = {
      main = {
        network_name = "production"
        subnet_name  = "odb_cogito"
      }
    }
  }

  ecp_util = {
    name                = "ecputil"
    image_name          = "default_windows"
    key_vault_name      = "production"
    location_name       = "production"
    resource_group_name = "odb"
    subscription_name   = "production"
    os_type             = "Windows"

    tags = {
      epic-app = "odb-ecp-util"
    }

    network_interfaces = {
      main = {
        network_name = "production"
        subnet_name  = "odb_cogito"
      }
    }
  }

  caboodle_db = {
    name                = "cbd"
    image_name          = "default_windows"
    key_vault_name      = "production"
    location_name       = "production"
    resource_group_name = "cogito_servers"
    subscription_name   = "production"
    os_type             = "Windows"

    tags = {
      epic-app = "caboodle-db"
    }

    network_interfaces = {
      main = {
        network_name = "production"
        subnet_name  = "odb_cogito"
      }
    }
  }

  clarity_db = {
    name                = "cld"
    image_name          = "default_windows"
    key_vault_name      = "production"
    location_name       = "production"
    resource_group_name = "cogito_servers"
    subscription_name   = "production"
    os_type             = "Windows"

    tags = {
      epic-app = "clarity-db"
    }

    network_interfaces = {
      main = {
        network_name = "production"
        subnet_name  = "odb_cogito"
      }
    }
  }

  cubes = {
    name                = "cub"
    image_name          = "default_windows"
    key_vault_name      = "production"
    location_name       = "production"
    resource_group_name = "cogito_servers"
    subscription_name   = "production"
    os_type             = "Windows"

    tags = {
      epic-app = "cubes"
    }

    network_interfaces = {
      main = {
        network_name = "production"
        subnet_name  = "odb_cogito"
      }
    }
  }

  caboodle_console = {
    name                = "cbc"
    image_name          = "default_windows"
    key_vault_name      = "production"
    location_name       = "production"
    resource_group_name = "cogito_clients"
    subscription_name   = "production"
    os_type             = "Windows"

    tags = {
      epic-app = "caboodle-console"
    }

    network_interfaces = {
      main = {
        network_name = "production"
        subnet_name  = "wss"
      }
    }
  }

  bi_restful = {
    name                = "bir"
    image_name          = "default_windows"
    key_vault_name      = "production"
    location_name       = "production"
    resource_group_name = "cogito_clients"
    subscription_name   = "production"
    os_type             = "Windows"

    tags = {
      epic-app = "birestful"
    }

    network_interfaces = {
      main = {
        network_name = "production"
        subnet_name  = "wss"
      }
    }
  }

  slicer_dicer = {
    name                = "sld"
    image_name          = "default_windows"
    key_vault_name      = "production"
    location_name       = "production"
    resource_group_name = "cogito_clients"
    subscription_name   = "production"
    os_type             = "Windows"

    tags = {
      epic-app = "slicerdicer"
    }

    network_interfaces = {
      main = {
        network_name = "production"
        subnet_name  = "wss"
      }
    }
  }
}
