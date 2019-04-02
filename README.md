# Container Escape Bounty CTF

This repository contains config to deploy and install virtual machines for a
"Container Escape Bounty" Capture the Flag (CTF) game based on [contained.af](https://github.com/genuinetools/contained.af).

It uses a modified version of contained.af that can be found here: TODO

## Setup

### Requirements

* AWS IAM credentials for programmatic access to EC2 and Route53.
  Provide them [through environment variables or a shared credentials file](https://www.terraform.io/docs/providers/aws/#authentication)
  to Terraform.

### Terraform

Terraform is used to provision virtual machines.

Prepare `terraform.tfvars` from its template file:

```
cd terraform
cp terraform.tfvars.tmpl terraform.tfvars
```

Edit `terraform.tfvars` and add your variables. Take a look at `variables.tf`
to learn about optional variables that you might want to set (for example
the name of the VM).

Run terraform to create AWS instances:

```
terraform init
terraform apply
```

To clean up the AWS resources:

```
terraform destroy
```

## Usage

Go to `https://<instance_name>.<dns_zone>` to access the contained.af web interface.

## Slack channel

Join the [CNCF slack](https://slack.cncf.io/) and the [#containerescape
channel](https://cloud-native.slack.com/messages/containerescape/).
