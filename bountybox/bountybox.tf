provider "aws" {
  region = "${var.aws_region}"
}

# Flatcar Linux - https://www.flatcar-linux.org/
data "aws_ami" "flatcar" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Flatcar-stable-*-hvm"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["075585003325"]
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "template_file" "systemd" {
  template = "${file("${var.distro}/cloudinit.yaml.tmpl")}"

  vars = {
    domain         = "${var.instance_name}.${var.dns_zone}"
    local_git_repo = "${var.distro == "flatcar" ? "/home/core/go/src/github.com/kinvolk/contained.af" : "/home/ubuntu/go/src/github.com/kinvolk/contained.af"}"
  }
}

data "template_cloudinit_config" "ubuntu" {
  part {
    content_type = "text/cloud-config"
    content      = "${data.template_file.systemd.rendered}"
  }
}

data "ct_config" "flatcar" {
  content      = "${data.template_file.systemd.rendered}"
  pretty_print = false
}

resource "aws_instance" "bountybox" {
  ami           = "${var.distro == "flatcar" ? data.aws_ami.flatcar.id : data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.key_pair_name}"

  vpc_security_group_ids = ["${aws_security_group.bountybox.id}"]
  subnet_id = "${aws_subnet.bountybox.id}"

  user_data = "${var.distro == "flatcar" ? data.ct_config.flatcar.rendered: data.template_cloudinit_config.ubuntu.rendered}"

  tags = {
    Name = "${var.instance_name}"
  }
}

resource "aws_security_group" "bountybox" {
  name_prefix = "bountybox_sg"
  vpc_id      = "${aws_vpc.bountybox.id}"
}

# Ingress rules to allow traffic for ssh, http, and https.
resource "aws_security_group_rule" "allow_ssh" {
  type        = "ingress"
  from_port   = 22
  to_port     = 22
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.bountybox.id}"
}

resource "aws_security_group_rule" "allow_http" {
  type        = "ingress"
  from_port   = 80
  to_port     = 80
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.bountybox.id}"
}

resource "aws_security_group_rule" "allow_https" {
  type        = "ingress"
  from_port   = 443
  to_port     = 443
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.bountybox.id}"
}

resource "aws_security_group_rule" "allow_container" {
  type        = "ingress"
  from_port   = 10000
  to_port     = 10000
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.bountybox.id}"
}

resource "aws_security_group_rule" "allow_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.bountybox.id}"
}

resource "aws_route53_record" "bountybox" {
  zone_id = "${var.dns_zone_id}"
  name    = "${var.instance_name}.${var.dns_zone}"
  type    = "A"
  ttl     = "300"
  records  = ["${aws_eip.ip-bountybox.public_ip}"]
}
