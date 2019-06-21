resource "null_resource" "provision" {
  connection {
    type    = "ssh"
    host    = "${aws_eip.ip-bountybox.public_ip}"
    user    = "${lookup(local.distro_user_name, var.distro)}"
    timeout = "3m"
  }

  provisioner "file" {
    source      = "${path.module}/provisioning"
    destination = "~/"
  }

  provisioner "remote-exec" {
    inline = "domain='${local.domain}' contained_af_image=${var.contained_af_image} bash ~/provisioning/${var.distro}.bash"
  }

  provisioner "remote-exec" {
    inline = "sudo sh -c \"echo ${random_string.flag_in_var_tmp.result} > /var/tmp/FLAG && chmod 0600 /var/tmp/FLAG\""
  }

  // /var/tmp/shared is mounted from the hostpath into the containers
  // spawned by researchers if they select the weak docker profile. We
  // create the directory so that the mount does not fail.
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /var/tmp/shared",
      "sudo touch /var/tmp/shared/THIS_IS_NOT_THE_FLAG_YOU_ARE_LOOKING_FOR",
    ]
  }
}
