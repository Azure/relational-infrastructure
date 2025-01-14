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
  type = map(string)

  default = {
    # Client tier
    arr                 = "arr"
    bca_pc              = "bcp"
    bca_web             = "bcw"
    care_everywhere     = "cev"
    care_everywhere_arr = "car"
    digital_signing     = "dss"
    epiccare_link       = "ecl"
    hyperspace_web      = "hsw"
    hyperspace          = "hsp"
    hyperdrive          = "hdv"
    interconnect        = "icn"
    system_pulse        = "sps"
    web_blob            = "wbs"
    eps                 = "eps"
    kuiper              = "kpr"
    mychart             = "myc"
    sts                 = "sts"
    welcome_web         = "wwb"
    citrix_cc           = "ccc"
    citrix_vda          = "cvd"
    willow              = "wlw"
    image_exchange      = "imx"

    # Cogito tier
    caboodle_db      = "cbd"
    clarity_db       = "cld"
    caboodle_console = "cbc"
    clarity_console  = "clc"
    caboodle_etl     = "cbe"
    slicer_dicer     = "sld"
    bi_restful       = "bir"
    cubes            = "cub"

    # ODB tier
    odb          = "odb"
    odb_ecp_app  = "oea"
    odb_ecp_util = "oeu"
    rpt          = "rpt"
    rpt_ecp_util = "reu"
  }

  nullable    = false
  description = "The application prefixes to use for virtual machine resources."
}
