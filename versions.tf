terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "~> 4.0"
      configuration_aliases = [aws.primary, aws.secondary]
    }
  }
  required_version = ">= 0.13"
}

provider "aws" { 
region = "us-west-1"
}

provider "aws" {
alias = "primary"
region = "us-west-1"
}

provider "aws" {
  alias = "secondary"
  region = "us-east-1"
  
}
