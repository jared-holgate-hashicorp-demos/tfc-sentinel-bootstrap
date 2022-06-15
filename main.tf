provider "github" {
  token = var.github_token
  owner = var.github_organization
}

provider "tfe" {}

provider "random" {}

# Random pet name to use in resource names
resource "random_pet" "prefix" {
  length = 2
  prefix = var.prefix
}

# Create OAUTH client to use for VCS-backed repos and attaching policy-sets
resource "tfe_oauth_client" "demo" {
  count = var.oauth_client_token_id == null ? 1 : 0
  organization     = var.organization
  api_url          = "https://api.github.com"
  http_url         = "https://github.com"
  oauth_token      = var.github_token
  service_provider = "github"
}

locals {
  tfe_token_id = var.oauth_client_token_id != null ? var.oauth_client_token_id : tfe_oauth_client.demo[0].oauth_token_id
}

# Add modules to PMR
resource "tfe_registry_module" "two-tier-registry-module" {
  for_each = toset(var.pmr-modules)
  vcs_repo {
    display_identifier = each.key
    identifier         = each.key
    oauth_token_id     = local.tfe_token_id
  }
}

# Create self-service workspace and associated policies 
module "self-service-workspace" {
  source             = "./modules/workspace"
  organization       = var.organization
  workspace_name     = "${random_pet.prefix.id}-self-service"
  sentinel_repo      = var.sentinel_repo
  workspace_template = var.self_service_template
  tfe_oauth_token_id = local.tfe_token_id
  tag_names          = ["self-service", "automated"]
}

# Create trusted workspace and associated policies 
module "trusted-workspace" {
  source             = "./modules/workspace"
  organization       = var.organization
  workspace_name     = "${random_pet.prefix.id}-trusted"
  sentinel_repo      = var.sentinel_repo
  workspace_template = var.self_service_template
  tfe_oauth_token_id = local.tfe_token_id
  tag_names          = ["trusted", "automated"]
}
