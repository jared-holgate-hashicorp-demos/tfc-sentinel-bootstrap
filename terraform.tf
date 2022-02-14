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
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }

  cloud {
    organization = "richard-russell-org"
    workspaces {
      name = "tfc-sentinel-bootstrap"
    }
  }

}
