locals {
  domain_apparmor = "${var.instance_name}.apparmor.${var.dns_zone}"
  domain_selinux  = "${var.instance_name}.selinux.${var.dns_zone}"

  apparmor_instance_name = "${var.instance_name}_apparmor"
  selinux_instance_name  = "${var.instance_name}_selinux"
}

# Following are three arrays that are used in provisioning. Other way to
# implement this would be to create list of maps with keys as user, ip and
# domain but creating list of maps does not work well here because
# interpolating the array returns string and not map.
#
# The values at any particular index in following arrays belong to same
# entitiy. So while adding any new value make sure that you follow the order.
locals {
  machine_users = ["ubuntu", "fedora"]

  machine_ips = [
    "${aws_eip.ip_bountybox_apparmor.public_ip}",
    "${aws_eip.ip_bountybox_selinux.public_ip}",
  ]

  machine_domains = [
    "${local.domain_apparmor}",
    "${local.domain_selinux}",
  ]
}
