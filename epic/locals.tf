locals {
  # We only use [default_location] in places that are theoretically inconsequential, 
  # like resource group locations.

  default_location            = values(var.locations)[0]
  network_resource_group_name = "${var.deployment_prefix}-networks"
}
