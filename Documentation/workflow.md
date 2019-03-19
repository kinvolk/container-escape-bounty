# Workflow

The workflows described below are not all implemented in the first phase of the project. 

## Actors

- Adm: Administrators: responsible for deploying the bounty boxes for security researchers.
- SR: Security researchers: are given access to a bounty box

## Scenario: new security researcher

- SR asks Adm to be given access to a bounty box
- Adm chooses parameters for the bounty box:
  - the content of the flag file
- Adm deploys a new bounty box
- Adm gives the following information to SR:
  - URL to the bounty box web portal
  - login and password

## Scenario: a security research session

- SR goes to the bounty box web portal
- SR chooses parameters for the container to be started from the bounty box web portal:
  - container image
  - environment variables
  - command
- SR clicks on start
- SR types commands on the web terminal

## Scenario: security researcher found an issue

### Content of the flag file discovered

- SR managed to get access to the flag file
- SR sends the content of the flag file to Adm
- Adm checks that the content matches with their database

### New flag file installed

- SR managed to install a new flag file on the host filesystem
- SR informs Adm of the file path and its content
- Adm checks if the installation at this filepath is considered as a vulnerability to be rewarded
- Adm connects to the bounty box with ssh and checks
