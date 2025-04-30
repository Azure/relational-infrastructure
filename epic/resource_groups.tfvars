resource_groups = {
  # These are the default resource groups included in the deployment.
  # Feel free to reconfigure resource groups to fit your needs. 
  # When reconfiguring resource groups, be sure to update resource_group_name
  # on related objects like var.virtual_machine_sets, var.networks, etc.

  shared = {
    location_name     = "production"
    subscription_name = "production"
    name              = "shared"
  }

  networks = {
    location_name     = "production"
    subscription_name = "production"
    name              = "networks"
  }

  arr = {
    location_name     = "production"
    subscription_name = "production"
    name              = "arr"
  }

  bca = {
    location_name     = "production"
    subscription_name = "production"
    name              = "bca"
  }

  care_everywhere = {
    location_name     = "production"
    subscription_name = "production"
    name              = "care-everywhere"
  }

  digital_signing = {
    location_name     = "production"
    subscription_name = "production"
    name              = "dss"
  }

  epiccare_link = {
    location_name     = "production"
    subscription_name = "production"
    name              = "epiccare-link"
  }

  hyperspace_web = {
    location_name     = "production"
    subscription_name = "production"
    name              = "hyperspace-web"
  }

  hyperspace = {
    location_name     = "production"
    subscription_name = "production"
    name              = "hyperspace"
  }

  interconnect = {
    location_name     = "production"
    subscription_name = "production"
    name              = "interconnect"
  }

  mpsql = {
    location_name     = "production"
    subscription_name = "production"
    name              = "mpsql"
  }

  system_pulse = {
    location_name     = "production"
    subscription_name = "production"
    name              = "system-pulse"
  }

  web_blob = {
    location_name     = "production"
    subscription_name = "production"
    name              = "wbs"
  }

  eps = {
    location_name     = "production"
    subscription_name = "production"
    name              = "eps"
  }

  kuiper = {
    location_name     = "production"
    subscription_name = "production"
    name              = "kuiper"
  }

  mychart = {
    location_name     = "production"
    subscription_name = "production"
    name              = "mychart"
  }

  sts = {
    location_name     = "production"
    subscription_name = "production"
    name              = "sts"
  }

  citrix_cc = {
    location_name     = "production"
    subscription_name = "production"
    name              = "citrix-cc"
  }

  willow = {
    location_name     = "production"
    subscription_name = "production"
    name              = "willow"
  }

  image_exchange = {
    location_name     = "production"
    subscription_name = "production"
    name              = "image-exchange"
  }

  cogito_clients = {
    location_name     = "production"
    subscription_name = "production"
    name              = "cogito-clients"
  }

  cogito_servers = {
    location_name     = "production"
    subscription_name = "production"
    name              = "cogito-servers"
  }

  odb = {
    location_name     = "production"
    subscription_name = "production"
    name              = "odb"
  }
}
