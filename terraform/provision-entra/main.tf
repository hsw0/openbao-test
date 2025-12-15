terraform {
  required_version = "~> 1.11"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.2"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.7.0"
    }
  }
}

provider "azuread" {
  tenant_id = var.entra_tenant_id
}
