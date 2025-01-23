locals {
  alt_location            = lower(var.locations.alt)
  primary_location        = lower(var.locations.primary)
  alt_location_prefix     = local.prefixes.locations[local.alt_location]
  primary_location_prefix = local.prefixes.locations[local.primary_location]

  prefixes = {
    locations = {
      southafricanorth   = "safn"
      eastasia           = "easa"
      southeastasia      = "seas"
      australiaeast      = "ause"
      brazilsouth        = "brzs"
      canadacentral      = "cacn"
      chinanorth3        = "chn3"
      northeurope        = "neur"
      westeurope         = "weur"
      francecentral      = "frcn"
      germanywestcentral = "gewc"
      centralindia       = "cind"
      israelcentral      = "islc"
      italynorth         = "ityn"
      japaneast          = "jape"
      koreacentral       = "korc"
      norwayeast         = "nore"
      polandcentral      = "polc"
      qatarcentral       = "qtrc"
      swedencentral      = "swdc"
      switzerlandnorth   = "swzn"
      uksouth            = "ukso"
      southcentralus     = "scus"
      westus2            = "wus2"
      westus3            = "wus3"
      centralus          = "cnus"
      eastus             = "esus"
      eastus2            = "eus2"
    }
  }
}
