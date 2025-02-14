networks = {
  primary = {
    dmz = {
      address_space          = "10.0.0.0/16"
      enable_ddos_protection = true
      dns_ip_addresses = [
        "10.0.0.250",
        "10.0.0.251"
      ]
      subnets = {
        firewall = {
          address_space = "10.0.0.0/24"
        }
        production = {
          address_space = "10.0.1.0/24"
        }
        non_production = {
          address_space = "10.0.2.0/24"
        }
      }
    }
    shared_infra = {
      address_space = "10.1.0.0/16"
      subnets = {
        gateway = {
          address_space = "10.1.0.0/24"
        }
        management = {
          address_space = "10.1.1.0/24"
        }
      }
    }
    main = {
      address_space = "10.2.0.0/16"
      subnets = {
        cogito = {
          address_space = "10.2.0.0/24"
        }
        odb = {
          address_space = "10.2.1.0/24"
        }
        wss = {
          address_space = "10.2.2.0/24"
        }
      }
    }
    hyperspace = {
      address_space = "10.3.0.0/16"
      subnets = {
        hyperspace = {
          address_space = "10.3.0.0/24"
        }
      }
    }
    hyperspace_web = {
      address_space = "10.4.0.0/16"
      subnets = {
        hyperspace_web = {
          address_space = "10.4.0.0/24"
        }
      }
    }
  }
  alt = {
    dmz = {
      address_space          = "10.10.0.0/16"
      enable_ddos_protection = true
      subnets = {
        firewall = {
          address_space = "10.10.0.0/24"
        }
        production = {
          address_space = "10.10.1.0/24"
        }
        non_production = {
          address_space = "10.10.2.0/24"
        }
      }
    }
    shared_infra = {
      address_space = "10.11.0.0/16"
      subnets = {
        gateway = {
          address_space = "10.11.0.0/24"
        }
        management = {
          address_space = "10.11.1.0/24"
        }
      }
    }
    main = {
      address_space = "10.12.0.0/16"
      subnets = {
        cogito = {
          address_space = "10.12.0.0/24"
        }
        odb = {
          address_space = "10.12.1.0/24"
        }
        wss = {
          address_space = "10.12.2.0/24"
        }
      }
    }
    hyperspace = {
      address_space = "10.13.0.0/16"
      subnets = {
        hyperspace = {
          address_space = "10.13.0.0/24"
        }
      }
    }
    hyperspace_web = {
      address_space = "10.14.0.0/16"
      subnets = {
        hyperspace_web = {
          address_space = "10.14.0.0/24"
        }
      }
    }
  }
}
