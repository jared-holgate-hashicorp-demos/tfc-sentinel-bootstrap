# Random pet name to use in resource names
resource "random_pet" "prefix" {
  length = 2
  prefix = var.prefix
}


# Create copy of terraform-guides repo to for use as a source for policy-sets
# Requires a local fork of terraform-guides configured as a template
resource "github_repository" "terraform-guides" {
  name        = "${random_pet.prefix.id}-terraform-guides"
  description = "Copy of terraform-guides for ${random_pet.prefix.id} policy-sets"

  visibility = "public"

  template {
    owner      = var.tfguides_template_owner
    repository = var.tfguides_template_repository
  }
}

# Create a TFC workspace for the demo
resource "tfe_workspace" "demo" {
  name         = random_pet.prefix.id
  organization = var.organization
  tag_names    = ["demo", "app"]
}

# Create OAUTH client to use for attaching policy-sets
resource "tfe_oauth_client" "demo" {
  organization     = var.organization
  api_url          = "https://api.github.com"
  http_url         = "https://github.com"
  oauth_token      = var.github_policy_token
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
    identifier         = "${var.tfguides_template_owner}/${var.tfguides_template_repository}"
    branch             = "master"
    ingress_submodules = false
    oauth_token_id     = tfe_oauth_client.demo.oauth_token_id
  }
}
