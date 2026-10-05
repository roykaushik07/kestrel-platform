variable "ghcr_credentials_secret_arn" {
  description = "Secrets Manager secret (ecr-pullthroughcache/ prefix) holding GHCR username and token."
  type        = string
}
