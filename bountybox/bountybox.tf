provider "aws" {
  region = "${var.aws_region}"
}

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

  owners = ["075585003325"] # Flatcar
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

resource "aws_instance" "bountybox" {
  ami           = "${var.distro == "flatcar" ? data.aws_ami.flatcar.id : data.aws_ami.ubuntu.id}"
  instance_type = "${var.instance_type}"
  key_name      = "${var.key_pair_name}"

  vpc_security_group_ids = ["${aws_security_group.bountybox.id}"]
  subnet_id = "${aws_subnet.bountybox.id}"

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

resource "aws_security_group_rule" "allow_egress" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = "${aws_security_group.bountybox.id}"
}
