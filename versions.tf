terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    key = "terraform/state"
  }

  required_providers {
    oci = {
      source  = "hashicorp/oci"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}
