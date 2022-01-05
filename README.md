Demo Project
==============================

Summary
---------
This repo contains configuration files for the spin up Demo environment from scratch on AWS.

Documentation
-------------

Software Versions
---------
ubuntu: 21.04
docker: >~
awscli: >~

Directory structure
-------------------
    .
    ├── terraform        	# terraform scripts for spin up env on aws
    ├── src           	    # custom scripts for aws
    ├── Makefile          	# Makefile that helps build/spinup/update/delete env (see "make help")
    └── README.md

Install steps
-------------------
# Requirements

0.0: This scrip currently tested only on ubuntu 21.04!

0.1: For spin up, env we need installed and configure AWS CLI
https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html
For do this first we neeed create IAM User in aws console.

# NOTE This script using aws credentials from $USER/.aws/ directory!!!

0.2:
Also we need to have installed "make" and "docker" on the host

```sh
sudo apt-get update
sudo apt-get install make
````

0.3:
For docker installation please read the official docs 
https://docs.docker.com/engine/install/ubuntu/

1: Clone repo to local env

```sh
git clone git@github.com:mula-dm/aws_demo.git
```

2: Before starting, we need to create override.tf file on terraform directory

```sh
cd terraform
mv override.tf_example override.tf
```
And edit this file.
Namely, you need to specify your SSS Pub key, it need for ec2 instance. 


3: Prepare terraform and custom scripts

```sh
make init
```

4: Run terraform plan

```sh
make tf_plan
```

5: Run terraform apply and confirm the terraform action (type: yes) 

```sh
make tf_apply
```

6: After this, we have to wait until the terraform roll out the stack.
It takes approximately 5 minutes

This script creates the following resources:
 - vpc
 - security group
 - route53 zone and records
 - self signed tls crt
 - ec2_instance with web server (need for testing)
 - Application Load Balancer

7: Also we can use additional commands to list ell resources in AWS region, or list ec2 instances or VPC.

```sh
make list_all
make list_ec2
make list_vpc
```

NOTES:
-------------
This POC use "demo.local" domain, in a nutshell, local domain
so for test this we need to edit the local host's file.

For detec current alb ip you can yuse following command
```sh
aws ec2 describe-network-interfaces --filters Name=description,Values="ELB app/demo-alb/*" --query 'NetworkInterfaces[*].Association.PublicIp' --output text
```