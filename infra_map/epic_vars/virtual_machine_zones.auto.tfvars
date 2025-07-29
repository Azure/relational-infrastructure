# Use this file to override VM set zone distribution.
# Entries here map one-to-one with VM sets defined in var.virtual_machines.
# Unless overridden here, zone distribution is even across zones 1-3.
# Adjust as capacity constraints demand.

virtual_machine_set_zone_distribution = {
  odb      = { even = ["1"] } # Pin ODB to zone 1
  ecp_app  = { even = ["1"] } # Pin ECP servers to zone 1 (next to ODB)
  ecp_util = { even = ["1"] } # Pin ECP utility servers to zone 1 (next to ODB)
  rpt      = { even = ["2"] } # Pin RPT to zone 2

  care_everywhere = {
    custom = {
      "1" = 2
      "2" = 8
    }
  }
}
