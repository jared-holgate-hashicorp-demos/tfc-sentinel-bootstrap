variable "prefix" {
  type    = string
  default = "tfc-sentinel-demo"
  description = "String prefix for the workspace and policy-sets"
}

variable "tfguides_template_owner" {
  type    = string
  default = "richard-russell"
  description = "Github organization of the fork of hashicorp/terraform-guides used as a template"
}

variable "tfguides_template_repository" {
  type    = string
  default = "terraform-guides"
  description = "Github repository of the fork of hashicorp/terraform-guides used as a template"
}

variable "organization" {
  type    = string
  default = "richard-russell-org"
  description = "TFC/TFE organization used for the demo"
}

variable "github_policy_token" {
  type        = string
  description = "github oauth token for attaching policy set"
}

