variable "prefix" {
  type        = string
  default     = "tfc-sentinel-demo"
  description = "String prefix for the workspace and policy-sets"
}

variable "tfguides_template_owner" {
  type        = string
  description = "Github organization of the fork of hashicorp/terraform-guides used as a template"
}

variable "tfguides_template_repository" {
  type        = string
  description = "Github repository of the fork of hashicorp/terraform-guides used as a template"
}

variable "organization" {
  type        = string
  description = "TFC/TFE organization used for the demo"
}

variable "github_token" {
  type        = string
  description = "github oauth token for creating repos and attaching policy set"
}
