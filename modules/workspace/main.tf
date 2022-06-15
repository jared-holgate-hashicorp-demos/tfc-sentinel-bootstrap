variable "organization" {
  type        = string
  description = "The organization under which to create the workspace"
}

variable "sentinel_repo" {
  type        = string
  description = "The github Sentinel policy repo"
}

variable "tag_names" {
  type = list(string)
  description = "Tags to apply to the workspace"
  default = ["automated"]
}

variable "tfe_oauth_token_id" {
    type = string
    description = "Github oauth token id for TFC"
}

variable "workspace_name" {
  type        = string
  description = "The name of the workspace"
}

variable "workspace_template" {
  type        = string
  description = "The github template to use for the workspace repo"
}

data "github_repository" "sentinel_repo" {
   full_name = var.sentinel_repo
}

locals {
  # split github path into owner and repository (sentinel policy repo)
  sentinel_repo_tmp_list   = split("/", var.sentinel_repo)
  sentinel_repo_owner      = local.sentinel_repo_tmp_list[0]
  sentinel_repo_repository = local.sentinel_repo_tmp_list[1]

  # split github path into owner and repository (workspace template repo)
  workspace_tmp_list            = split("/", var.workspace_template)
  workspace_template_owner      = local.workspace_tmp_list[0]
  workspace_template_repository = local.workspace_tmp_list[1]
}

# Create branch for this workspace in the terraform-sentinel-policies fork
resource "github_branch" "policies_branch" {
  repository    = local.sentinel_repo_repository
  branch        = var.workspace_name
  source_branch = data.github_repository.sentinel_repo.default_branch
}

# Create copy of workspace template repo to use for a VCS backed workspace
resource "github_repository" "workspace" {
  name        = var.workspace_name
  description = "Repo for ${var.workspace_name} workspace"
  visibility  = "public"

  template {
    owner      = local.workspace_template_owner
    repository = local.workspace_template_repository
  }
}

# Create a TFC workspace
resource "tfe_workspace" "workspace" {
  name         = var.workspace_name
  organization = var.organization
  tag_names    = var.tag_names
  auto_apply   = true

}

# Apply policy sets
resource "tfe_policy_set" "cloud-agnostic" {
  name          = "${var.workspace_name}-cloud-agnostic"
  description   = "terraform-sentinel-policies cloud-agnostic policy set"
  organization  = var.organization
  policies_path = "cloud-agnostic"
  workspace_ids = [tfe_workspace.workspace.id]

  vcs_repo {
    identifier         = data.github_repository.sentinel_repo.full_name
    branch             = var.workspace_name
    ingress_submodules = false
    oauth_token_id     = var.tfe_oauth_token_id
  }
}

# Add policy-set parameter - the list of orgs whose PMRs we are allowed to use
resource "tfe_policy_set_parameter" "orgs" {
  key           = "organizations"
  value         = "[ \"${var.organization}\" ]"
  policy_set_id = tfe_policy_set.cloud-agnostic.id
}