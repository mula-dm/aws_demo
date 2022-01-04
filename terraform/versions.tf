terraform {
  #The required_version setting can be used to require a specific version of Terraform.
  #If the running version of Terraform doesn't match the constraints specified, Terraform will show an error and exit.
  required_version = ">= 0.15.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}