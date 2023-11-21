terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.44.1"
    }
  }
  cloud {
    organization = "koichi-furukawa"
    workspaces {
      name = "learn-terraform-dynamic-credentials"
    }
  }
}
