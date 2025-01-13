variable "location_prefixes" {
  type = object({
    alt     = optional(string, "a")
    primary = optional(string, "p")
  })

  nullable    = false
  description = "The location prefixes to use for resources."
}

variable "network_prefixes" {
  type = object({
    dmz            = optional(string, "dmznet")
    shared_infra   = optional(string, "sifnet")
    main           = optional(string, "mainet")
    hyperspace     = optional(string, "hspnet")
    hyperspace_web = optional(string, "hswnet")
  })

  nullable    = false
  description = "The prefixes to use for network resources."
}

variable "app_prefixes" {
  type = object({
    client = object({
      arr                 = optional(string, "arr")
      bca_pc              = optional(string, "bcp")
      bca_web             = optional(string, "bcw")
      care_everywhere     = optional(string, "cev")
      care_everywhere_arr = optional(string, "car")
      digital_signing     = optional(string, "dss")
      epiccare_link       = optional(string, "ecl")
      hyperspace_web      = optional(string, "hsw")
      hyperspace          = optional(string, "hsp")
      hyperdrive          = optional(string, "hdr")
      interconnect        = optional(string, "icn")
      mpsql               = optional(string, "sql")
      system_pulse        = optional(string, "sps")
      kuiper              = optional(string, "kpr")
      web_blob            = optional(string, "wbs")
      eps                 = optional(string, "eps")
      mychart             = optional(string, "myc")
      sts                 = optional(string, "sts")
      welcome_web         = optional(string, "wwb")
      citrix_cc           = optional(string, "ccc")
      citrix_vda          = optional(string, "cvd")
      willow              = optional(string, "wlw")
      image_exchange      = optional(string, "imx")
    })
    cogito = object({
      caboodle_db      = optional(string, "cad")
      clarity_db       = optional(string, "cld")
      caboodle_console = optional(string, "cac")
      clarity_console  = optional(string, "clc")
      caboodle_etl     = optional(string, "cae")
      slicer_dicer     = optional(string, "sld")
      bi_restful       = optional(string, "bir")
      cubes            = optional(string, "cub")
    })
    odb = object({
      odb          = optional(string, "odb")
      odb_ecp_app  = optional(string, "oea")
      odb_ecp_util = optional(string, "oeu")
      rpt          = optional(string, "rpt")
      rpt_ecp_util = optional(string, "reu")
    })
  })

  nullable    = false
  description = "The application prefixes to use for virtual machine resources."
}
