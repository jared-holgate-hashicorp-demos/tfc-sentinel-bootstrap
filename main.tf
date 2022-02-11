provider "github" {
  token = var.github_token
}

provider "tfe" {}

provider "random" {}

# Random pet name to use in resource names
resource "random_pet" "prefix" {
  length = 2
  prefix = var.prefix
}

locals {
  # split github path into owner and repository (sentinel policy forked repo)
  sentinel_repo_tmp_list   = split("/", var.sentinel_repo)
  sentinel_repo_owner      = local.sentinel_repo_tmp_list[0]
  sentinel_repo_repository = local.sentinel_repo_tmp_list[1]

  # split github path into owner and repository (self-service repo)
  self_service_tmp_list            = split("/", var.self_service_template)
  self_service_template_owner      = local.self_service_tmp_list[0]
  self_service_template_repository = local.self_service_tmp_list[1]

  # to-do: create trusted workspace
  # # split github path into owner and repository (trusted repo)
  # trusted_tmp_list            = split("/", var.trusted_template)
  # trusted_template_owner      = local.trusted_tmp_list[0]
  # trusted_template_repository = local.trusted_tmp_list[1]
}

# Existing repo forked from hashicorp/terraform-sentinel-policies
data "github_repository" "sentinel_repo" {
  full_name = var.sentinel_repo
}

# Create OAUTH client to use for VCS-backed repos and attaching policy-sets
resource "tfe_oauth_client" "demo" {
  organization     = var.organization
  api_url          = "https://api.github.com"
  http_url         = "https://github.com"
  oauth_token      = var.github_token
  service_provider = "github"
}

# Create self-service workspace and associated policies 

# Create branch for self-service policy-set in the terraform-sentinel-policies fork
resource "github_branch" "self-service-branch" {
  repository    = local.sentinel_repo_repository
  branch        = random_pet.prefix.id
  source_branch = data.github_repository.sentinel_repo.default_branch
}

# Create copy of self-service template repo to use for a VCS backed workspace
resource "github_repository" "self-service" {
  name        = "${random_pet.prefix.id}-self-service"
  description = "Self-service repo for ${random_pet.prefix.id} demo"

  visibility = "public"

  template {
    owner      = local.self_service_template_owner
    repository = local.self_service_template_repository
  }
}

# Create a TFC self-service workspace
resource "tfe_workspace" "selfservice" {
  name         = random_pet.prefix.id
  organization = var.organization
  tag_names    = ["demo", "selfservice"]
  auto_apply   = true
  vcs_repo {
    identifier     = github_repository.self-service.full_name
    oauth_token_id = tfe_oauth_client.demo.oauth_token_id
  }

}

# Apply policy sets
resource "tfe_policy_set" "cloud-agnostic" {
  name          = "${random_pet.prefix.id}-cloud-agnostic"
  description   = "terraform-sentinel-policies cloud-agnostic policy set"
  organization  = var.organization
  policies_path = "cloud-agnostic"
  workspace_ids = [tfe_workspace.selfservice.id]

  vcs_repo {
    identifier         = data.github_repository.sentinel_repo.full_name
    branch             = random_pet.prefix.id
    ingress_submodules = false
    oauth_token_id     = tfe_oauth_client.demo.oauth_token_id
  }
}

# Add policy-set parameter - the list of orgs whose PMRs we are allowed to use
resource "tfe_policy_set_parameter" "orgs" {
  key           = "organizations"
  value         = "[ \"${var.organization}\" ]"
  policy_set_id = tfe_policy_set.cloud-agnostic.id
}

# Add module to PMR
resource "tfe_registry_module" "two-tier-registry-module" {
  vcs_repo {
    display_identifier = "richard-russell/terraform-aws-tfc-demo-two-tier"
    identifier         = "richard-russell/terraform-aws-tfc-demo-two-tier"
    oauth_token_id     = tfe_oauth_client.demo.oauth_token_id
  }
}

# to-do: create trusted workspace and associated policies 
