terraform {
  required_providers {
    github = {
      source  = "integrations/github"
    }
    tfe = {
      source  = "hashicorp/tfe"
    }
    random = {
      source  = "hashicorp/random"
    }
  }
}
