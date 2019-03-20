variable "aws_region" {
  type        = "string"
  description = "AWS region to be deployed"
  default     = "eu-central-1"
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

