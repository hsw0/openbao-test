terraform {
  required_version = "~> 1.11"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.7.2"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "5.6.0"
    }
  }
}

provider "vault" {
  address = "http://localhost:8200"
  token   = var.vault_token
}
