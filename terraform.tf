terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "4.19.0"
    }
    tfe = {
      source  = "hashicorp/tfe"
      version = "0.27.0"
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

provider "github" {
  # Configuration options
  token = var.github_token
}

provider "tfe" {
  # Configuration options
}

provider "random" {
  # Configuration options
}