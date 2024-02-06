terraform {
  required_version = "~> 0.14"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    template = {
      source  = "hashcorp/template"
      version = "2.2.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  alias  = "use1"
}