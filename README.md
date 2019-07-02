# Container Escape Bounty CTF

Status: alpha, work in progress

This repository contains config to deploy and install virtual machines for a
"Container Escape Bounty" Capture the Flag (CTF) game based on [contained.af](https://github.com/genuinetools/contained.af).

It uses a modified version of contained.af that can be found here:
https://github.com/kinvolk/contained.af/tree/container-escape-bounty

## Setup

### Requirements

* AWS IAM credentials for programmatic access to EC2 and Route53.
  Provide them [through environment variables or a shared credentials file](https://www.terraform.io/docs/providers/aws/#authentication)
  to Terraform (e.g., `AWS_ACCESS_KEY_ID=… AWS_SECRET_ACCESS_KEY=… AWS_DEFAULT_REGION=… terraform …`).

Note: we recommend to use a separate AWS (sub)organization and account
that is not used for anything else.

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

Run terraform to create AWS instances (make sure to use the AWS IAM credentials as env vars or from the shared credentials file):

```
terraform init
terraform apply
```

To (re)run the provisioning scripts after a the virtual machines was
started, for example during development:

```
terraform taint null_resource.provision.0
terraform taint null_resource.provision.1
terraform apply -target null_resource.provision
```

Note: [terraform doesn't detect changes for copied directories](https://github.com/hashicorp/terraform/issues/6065)
i.e. you need to delete the `~/provisioning` directory on the node
first if you want terraform to resync it.

To clean up the AWS resources:

```
terraform destroy
```

#### As a terraform child module

The `terraform` folder can be used as a [terraform child module](https://www.terraform.io/docs/configuration/modules.html#calling-a-child-module)
alternatively.

Example:

```
locals {
	ssh_public_key = "ssh-rsa AAAA..."

	dns_zone = "contained.example.com"
	dns_zone_id = "ZZZZ"
}

module "demo" {
	source = "./terraform"

	instance_name = "demo"

	ssh_public_key = "${local.ssh_public_key}"

	dns_zone = "${local.dns_zone}"
	dns_zone_id = "${local.dns_zone_id}"
}
```

## Usage

To access the contained.af web interface visit following URLs respectively.

- With support of AppArmor `https://<instance_name>.apparmor.<dns_zone>`
- With support of SELinux `https://<instance_name>.selinux.<dns_zone>`

They are printed after `terraform apply`.
The HTTP basic auth password and the secret flag content is not printed
and can be found in `terraform.tfstate`.

Please follow the [workflow](Documentation/workflow.md)
and read more about the [profiles](Documentation/profiles.md).

When the above URLs cannot be accessed after creation, you may have been
rate-limited by [Let's Encrypt](https://letsencrypt.org/) which is used
to generate TLS certificates.
Please run `terraform destroy` and change the `instance_name` before you
run `terraform apply` to create the VMs with new domains.

## Slack channel

Join the [CNCF slack](https://slack.cncf.io/) and the [#containerescape
channel](https://cloud-native.slack.com/messages/containerescape/).
