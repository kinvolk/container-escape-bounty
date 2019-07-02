resource "null_resource" "provision" {
  count = "${length(local.machine_users)}"

  connection {
    type    = "ssh"
    host    = "${local.machine_ips[count.index]}"
    user    = "${local.machine_users[count.index]}"
    timeout = "3m"
  }

  provisioner "file" {
    source      = "${path.module}/provisioning"
    destination = "~/"
  }

  provisioner "remote-exec" {
    inline = "domain='${local.machine_domains[count.index]}' username='${var.username}' password='${random_string.password.result}' contained_af_image=${var.contained_af_image} bash ~/provisioning/${local.machine_users[count.index]}.bash"
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
