variable "cloudflare_api_token" {
  description = "Cloudflare API token scoped to DNS edit on kestrel-air.net."
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  type = string
}

variable "dispatch_db_password" {
  type      = string
  sensitive = true
}

variable "custody_ledger_password" {
  type      = string
  sensitive = true
}

variable "ghcr_credentials_secret_arn" {
  type = string
}

variable "alert_email" {
  type    = string
  default = "platform-oncall@kestrel-air.net"
}
