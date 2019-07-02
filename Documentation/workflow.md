# Workflow

The workflow describes how the administrators and researchers use this project.

## Actors

- Adm: Administrators: responsible for deploying the bounty boxes for security researchers.
- SR: Security researchers: are given access to a bounty box

## Scenario: new security researcher

- SR asks Adm to be given access to a bounty box
- Adm chooses parameters for the bounty box:
  - DNS zone, AWS DNS zone ID, and instance name
  - the Adm's ssh public key
  - optionally a different username for HTTP basic auth, a different AWS region
- Adm deploys a new bounty box through terraform (see [README](../README.md))
  - notes the URLs from the terraform output for the SR
  - notes the HTTP basic auth password for the SR from `password` in `terraform.tfstate` (16 characters)
  - notes the secret contents of `/var/tmp/FLAG` from `flag_in_var_tmp` in `terraform.tfstate` (32 characters) to verify claims of the SR
- Adm gives the following information to SR:
  - URL to the bounty box web portal
  - login (default username is `user`) and password
  - flagfile location on host is `/var/tmp/FLAG` (requires root permissions)

## Scenario: a security research session

- SR goes to the bounty box web portal
- SR chooses parameters for the container to be started from the bounty box web portal:
  - [container profile](profiles.md)
  - container image
  - open port
- SR clicks on start
- SR types commands on the web terminal to find weaknesses

## Scenario: security researcher found an issue

### Content of the flag file discovered

- SR managed to get access to the flag file
- SR sends the content of the flag file to Adm
- Adm checks that the content matches with their database

### New flag file installed in host filesystem

- SR managed to install a new flag file on the host filesystem, at a position that shouldn't be writable
- SR informs Adm of the file path and its content
- Adm checks if the installation at this filepath is considered as a vulnerability to be rewarded
- Adm connects to the bounty box with ssh and checks
  - AppArmor Ubuntu VM: `ssh ubuntu@…`, then `sudo -s`
  - SELinux Fedora VM: `ssh fedora@…`, then `sudo -s`
