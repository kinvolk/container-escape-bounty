# Container Escape Bounty

## How to try

Manual preparation:
- Get a key pair's name from the AWS console. Let's say its name is `testkey`.

Prepare `terraform.tfvars` from its template file.

```
cd bountybox
cp terraform.tfvars.tmpl terraform.tfvars
```

Customize `terraform.tfvars` if needed. For example:

```
sed -i 's,key_pair_name = "keyname",key_pair_name = "testkey",' terraform.tfvars
```

Run terraform to create AWS instances:

```
terraform init
terraform apply
```

To clean up the AWS resources:

```
terraform destroy
```

## Slack channel

Join the [CNCF slack](https://slack.cncf.io/) and the [#containerescape
channel](https://cloud-native.slack.com/messages/containerescape/).
