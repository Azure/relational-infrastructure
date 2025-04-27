virtual_machine_set_zone_distribution = {
  odb      = { even = ["1"] } # Pin ODB to zone 1
  ecp_app  = { even = ["1"] } # Pin ECP servers to zone 1 (alongside ODB)
  ecp_util = { even = ["1"] } # Pin ECP utility servers to zone 1 (alongside ODB)
  rpt      = { even = ["2"] } # Pin RPT to zone 2
}
