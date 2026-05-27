terraform {
  required_version = "1.15.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.44.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.76"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.2"
    }
  }

  backend "s3" {
    bucket       = "fileops-setup-tf-states"
    key          = "terraform.tfstate"
    region       = "ap-southeast-2"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

provider "tfe" {
  hostname = "app.terraform.io"
  token    = var.tfe_token
}
