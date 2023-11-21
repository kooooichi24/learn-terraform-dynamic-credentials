terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.44.1"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.46.0"
    }
  }
  cloud {
    organization = "koichi-furukawa"
    workspaces {
      name = "learn-terraform-dynamic-credentials"
    }
  }
}
