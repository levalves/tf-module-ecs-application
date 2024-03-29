terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
      configuration_aliases = [
        aws.dst
      ]
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2.2"
    }
  }
}
