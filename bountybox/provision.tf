resource "null_resource" "setup-docker" {
  connection {
    type = "ssh"
    host = "${aws_eip.ip-bountybox.public_ip}"
    user = "ubuntu"
    timeout = "3m"
  }

  provisioner "file" {
    source      = "setup-docker.sh"
    destination = "/tmp/setup-docker.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup-docker.sh",
      "/tmp/setup-docker.sh",
    ]
  }
}
