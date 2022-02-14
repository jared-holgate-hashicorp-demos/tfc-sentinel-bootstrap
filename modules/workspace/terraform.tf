terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "4.20.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.28.1"
    }
  }
}
