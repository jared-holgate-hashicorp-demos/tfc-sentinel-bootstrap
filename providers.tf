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
}

provider "github" {
  # Configuration options
}

provider "tfe" {
  # Configuration options
}

provider "random" {
  # Configuration options
}