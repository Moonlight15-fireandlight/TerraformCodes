terraform {

  required_providers {

    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.73"
    }

  }

  required_version = "1.7.5"

}

provider "aws" {

  region = "us-west-2"

}

provider "aws" {

  alias  = "east"
  region = "us-east-1"

}