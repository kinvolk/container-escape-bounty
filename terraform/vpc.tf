# VPC resources for vpc, subnets, elastic IP, internet gateway, and
# the routing table.
resource "aws_vpc" "bountybox" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.instance_name}"
  }
}

resource "aws_subnet" "bountybox" {
  vpc_id     = "${aws_vpc.bountybox.id}"
  cidr_block = "10.0.0.0/24"

  tags = {
    Name = "${var.instance_name}"
  }
}

resource "aws_eip" "ip_bountybox_apparmor" {
  instance = "${aws_instance.bountybox_apparmor.id}"
  vpc      = true

  tags = {
    Name = "${local.apparmor_instance_name}"
  }
}

resource "aws_eip" "ip_bountybox_selinux" {
  instance = "${aws_instance.bountybox_selinux.id}"
  vpc      = true

  tags = {
    Name = "${local.selinux_instance_name}"
  }
}

resource "aws_internet_gateway" "bountybox" {
  vpc_id = "${aws_vpc.bountybox.id}"

  tags = {
    Name = "${var.instance_name}"
  }
}

resource "aws_route_table" "bountybox" {
  vpc_id = "${aws_vpc.bountybox.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.bountybox.id}"
  }

  tags = {
    Name = "${var.instance_name}"
  }
}

resource "aws_route_table_association" "bountybox" {
  subnet_id      = "${aws_subnet.bountybox.id}"
  route_table_id = "${aws_route_table.bountybox.id}"
}
