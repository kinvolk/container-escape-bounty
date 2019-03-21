variable "aws_region" {
  type        = "string"
  description = "AWS region to be deployed"
  default     = "eu-central-1"
}

variable "distro" {
  type        = "string"
  description = "Linux Distro to be installed"
  default     = "ubuntu"
}

variable "instance_name" {
  type        = "string"
  description = "Name of the AWS instance"
  default     = "BountyBox"
}

variable "instance_type" {
  type        = "string"
  description = "Type of the AWS instance"
  default     = "t2.micro"
}

variable "key_pair_name" {
  type        = "string"
  description = "SSH public key"
}

variable "distro_user_name" {
  default = {
    "flatcar" = "core"
    "ubuntu"  = "ubuntu"
  }
}
