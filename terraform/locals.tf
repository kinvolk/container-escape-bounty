locals {
  domain = "${var.instance_name}.${var.dns_zone}"

  distro_user_name = {
    "flatcar" = "core"
    "ubuntu"  = "ubuntu"
  }
}
