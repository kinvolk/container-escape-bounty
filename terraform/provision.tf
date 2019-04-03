resource "null_resource" "provision" {
  connection {
    type = "ssh"
    host = "${aws_eip.ip-bountybox.public_ip}"
    user = "${lookup(local.distro_user_name, var.distro)}"
    timeout = "3m"
  }

  provisioner "file" {
    source = "${path.module}/provisioning"
    destination = "~/"
  }

  provisioner "remote-exec" {
    inline = "domain='${local.domain}' bash ~/provisioning/${var.distro}.bash"
  }
}
