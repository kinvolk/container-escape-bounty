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

data "aws_ami" "fedora" {
  most_recent = true

  filter {
    name   = "name"
    values = ["Fedora-Cloud-Base-*.x86_64-hvm-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["125523088429"]
}

resource "aws_key_pair" "ssh_public_key" {
  public_key = "${var.ssh_public_key}"
}

locals {
  machine_id = {
    flatcar = "${data.aws_ami.flatcar.id}"
    ubuntu  = "${data.aws_ami.ubuntu.id}"
    fedora  = "${data.aws_ami.fedora.id}"
  }
}

resource "aws_instance" "bountybox" {
  ami           = "${local.machine_id[var.distro]}"
  instance_type = "${var.instance_type}"
  key_name      = "${aws_key_pair.ssh_public_key.key_name}"

  vpc_security_group_ids = ["${aws_security_group.bountybox.id}"]
  subnet_id              = "${aws_subnet.bountybox.id}"

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

resource "aws_security_group_rule" "allow_custom_container" {
  type        = "ingress"
  from_port   = 36100
  to_port     = 36110
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
  records = ["${aws_eip.ip-bountybox.public_ip}"]
}
