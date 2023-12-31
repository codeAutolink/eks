
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.67.0"
    }
  }
  required_version = "1.4.6"
}

provider "aws" {
  region = var.region
}




provider "helm" {
  kubernetes {
    config_path = var.kube_config_path
  }
}



data "aws_availability_zones" "available" {}
