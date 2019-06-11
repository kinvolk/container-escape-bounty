/*
 * Required variables
 */

variable "ssh_public_key" {
  type        = "string"
  description = "SSH public key"
}

variable "dns_zone" {
  type        = "string"
  description = "AWS Route53 DNS Zone (e.g. aws.example.com)"
}

variable "dns_zone_id" {
  type        = "string"
  description = "AWS Route53 DNS Zone ID (e.g. 0123456789ABCD)"
}

/*
 * Optional variables
 */

variable "instance_name" {
  type        = "string"
  description = "Name of the AWS instance (e.g. BountyBox)"
  default     = "BountyBox"
}

variable "aws_region" {
  type        = "string"
  description = "AWS region to be deployed (e.g. eu-central-1, us-west-2)"
  default     = "eu-central-1"
}

variable "distro" {
  type        = "string"
  description = "Linux Distro to be installed (ubuntu, flatcar or fedora)"
  default     = "ubuntu"
}

variable "instance_type" {
  type        = "string"
  description = "Type of the AWS instance (e.g. t2.micro, t3.small)"
  default     = "t2.micro"
}

variable "contained_af_image" {
  type        = "string"
  description = "Image to use for contained.af"
  default     = "quay.io/kinvolk/contained.af:container-escape-bounty-latest"
}
