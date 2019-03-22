variable "aws_region" {
  type        = "string"
  description = "AWS region to be deployed (e.g. eu-central-1, us-west-2)"
  default     = "eu-central-1"
}

variable "distro" {
  type        = "string"
  description = "Linux Distro to be installed (ubuntu or flatcar)"
  default     = "ubuntu"
}

variable "dns_zone" {
  type        = "string"
  description = "AWS Route53 DNS Zone (e.g. aws.example.com)"
}

variable "dns_zone_id" {
  type        = "string"
  description = "AWS Route53 DNS Zone ID (e.g. 0123456789ABCD)"
}

variable "instance_name" {
  type        = "string"
  description = "Name of the AWS instance (e.g. BountyBox)"
  default     = "BountyBox"
}

variable "instance_type" {
  type        = "string"
  description = "Type of the AWS instance (e.g. t2.micro, t3.small)"
  default     = "t2.micro"
}

variable "key_pair_name" {
  type        = "string"
  description = "SSH public key's name from the AWS console (e.g. testkey)"
}

variable "distro_user_name" {
  default = {
    "flatcar" = "core"
    "ubuntu"  = "ubuntu"
  }
}
