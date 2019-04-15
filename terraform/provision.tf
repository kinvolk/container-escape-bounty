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

  provisioner "remote-exec" {
    inline = "sudo sh -c \"echo ${random_string.flag_in_var_tmp.result} > /var/tmp/FLAG && chmod 0600 /var/tmp/FLAG\""
  }
}
