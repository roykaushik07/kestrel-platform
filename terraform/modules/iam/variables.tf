variable "github_org" {
  type    = string
  default = "roykaushik07"
}

variable "oidc_provider_arn" {
  description = "EKS cluster OIDC provider ARN for IRSA trust."
  type        = string
}

variable "oidc_provider_host" {
  type = string
}

variable "mission_events_publish_policy_arn" {
  type = string
}

variable "custody_intake_consume_policy_arn" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
