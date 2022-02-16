# Terraform Cloud Sentinel Self-Service Demo

This demo shows how the features of Terraform Cloud can be used to enforce guardrails on a self-service workspace, to mandate use of the Private Module Registry. This is possible without having to know any Sentinel, thanks to the example policies.


## Prerequisites
- A github local fork of [hashicorp/terraform-sentinel-policies](https://github.com/hashicorp/terraform-sentinel-policies). The module will create a branch for each workspace, allowing different enforcement levels from the same base policies
- A github repository containing a module to be published in the PMR
- A github repository set up as a template, used to create repos for the two VCS-backed workspaces. This should contain root module resources and also call the PMR module.
- Github token with repo and delete_repo permissions, supplied to the module via the github_token variable.
- TFC/TFE token, stored in TFE_TOKEN env variable. Tested with User token, but Team token would be better practice


## Demo Flow
- Suggest running from CLI with remote execution in Terraform Cloud 
- `terraform apply`, which will
  - create the VCS-backed workspaces, trusted and self-service
  - publish a module in the PMR
  - create branches in the policies repo for each workspace
  - create a policy-set for each workspace linked to the policy-repo branches 
- Populate workspace variables for AWS credentials (or whatever is required for your TF code to work)
- Start a run in the trusted workspace. 
- Follow the self-service policy-set link and edit `sentinel.hcl` in the self-service branch cloud-agnostic. Set the enforcement level of `require-all-resources-from-pmr` to `hard-mandatory`
- Start a run in the self-service workspace. This will fail due to the PMR policy.
- Follow the source repo link from the self-service workspace. Edit `main.tf` to comment out the non-compliant data block and resource block.
- Watch the resulting run complete now the PMR check passes.
- Go back to the trusted workspace and show that the run passed first time as the PMR check was still advisory.
