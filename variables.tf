variable "prefix" {
  type        = string
  default     = "tfc-sentinel-demo"
  description = "String prefix for the workspace and policy-sets"
}

variable "tfguides_fork" {
  type        = string
  default     = "richard-russell/terraform-guides"
  description = "Github path of the fork of hashicorp/terraform-guides used for the policies"
}

variable "self_service_template" {
  type        = string
  description = "Github repo to use as a template for the self-service repo in the demo"
  default     = "richard-russell/tfc-sentinel-template-repo-aws"
}

# to-do: create trusted workspace
# variable "trusted_template" {
#   type        = string
#   description = "Github repo to use as a template for the trusted repo in the demo"
#   default     = "richard-russell/tfc-sentinel-template-repo-aws"
# }

variable "organization" {
  type        = string
  description = "TFC/TFE organization used for the demo"
}

variable "github_token" {
  type        = string
  description = "github oauth token for creating repos and attaching policy set"
}

