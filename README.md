# Terraform Cloud Sentinel Self-Service Demo

This module creates a workspace and attaches Sentinel policy sets based on 
hashicorp/terraform-guides.

## Prerequisites
- A github repository forked from hashicorp/terraform-guides
- Github token with repo and delete_repo permissions, supplied to the module via the github_token variable.
- TFC/TFE token, stored in TFE_TOKEN env variable.

## Example
```terraform apply -var="github_policy_token=$GITHUB_TOKEN"```


