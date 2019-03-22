resource "null_resource" "setup-cloudinit" {
  connection {
    type = "ssh"
    host = "${aws_eip.ip-bountybox.public_ip}"
    user = "${lookup(var.distro_user_name, var.distro)}"
    timeout = "3m"
  }
}
