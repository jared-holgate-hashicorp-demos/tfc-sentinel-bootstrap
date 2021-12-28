# Random pet name to use in resource names
resource "random_pet" "prefix" {
  length = 2
  prefix = var.prefix
}

locals {
  # split github path into owner and repository (terraform guides forked repo)
  tfguides_tmp_list            = split("/", var.tfguides_template)
  tfguides_template_owner      = local.tfguides_tmp_list[0]
  tfguides_template_repository = local.tfguides_tmp_list[1]

  # split github path into owner and repository (self-service repo)
  self_service_tmp_list            = split("/", var.self_service_template)
  self_service_template_owner      = local.self_service_tmp_list[0]
  self_service_template_repository = local.self_service_tmp_list[1]

}

# Create copy of terraform-guides repo to use as a source for policy-sets
# Requires a local fork of terraform-guides configured as a template
resource "github_repository" "terraform-guides" {
  name        = "${random_pet.prefix.id}-terraform-guides"
  description = "Copy of terraform-guides for ${random_pet.prefix.id} policy-sets"

  visibility = "public"

  template {
    owner      = local.tfguides_template_owner
    repository = local.tfguides_template_repository
  }
}

# Create copy of self-service template repo to use as a VCS backed
resource "github_repository" "self-service" {
  name        = "${random_pet.prefix.id}-self-service"
  description = "Self-service repo for ${random_pet.prefix.id} demo"

  visibility = "public"

  template {
    owner      = local.self_service_template_owner
    repository = local.self_service_template_repository
  }
}

# Create a TFC workspace for the demo
resource "tfe_workspace" "demo" {
  name         = random_pet.prefix.id
  organization = var.organization
  tag_names    = ["demo", "selfservice"]
  vcs_repo {
    identifier     = github_repository.self-service.full_name
    oauth_token_id = tfe_oauth_client.demo.oauth_token_id
  }

}

# Create OAUTH client to use for VCS-backed repos and attaching policy-sets
resource "tfe_oauth_client" "demo" {
  organization     = var.organization
  api_url          = "https://api.github.com"
  http_url         = "https://github.com"
  oauth_token      = var.github_token
  service_provider = "github"
}

# Apply policy sets
resource "tfe_policy_set" "cloud-agnostic" {
  name          = "${random_pet.prefix.id}-cloud-agnostic"
  description   = "terraform-guides cloud-agnostic third-generation policy set"
  organization  = var.organization
  policies_path = "governance/third-generation/cloud-agnostic"
  workspace_ids = [tfe_workspace.demo.id]

  vcs_repo {
    identifier         = github_repository.terraform-guides.full_name
    branch             = "master"
    ingress_submodules = false
    oauth_token_id     = tfe_oauth_client.demo.oauth_token_id
  }
}

# Add module to PMR

resource "tfe_registry_module" "two-tier-registry-module" {
  vcs_repo {
    display_identifier = "richard-russell/terraform-aws-tfc-demo-two-tier"
    identifier         = "richard-russell/terraform-aws-tfc-demo-two-tier"
    oauth_token_id     = tfe_oauth_client.demo.oauth_token_id
  }
}
