variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for kestrel-air.net."
  type        = string
}

variable "vpc_id" {
  description = "VPC that the private hosted zone is associated with."
  type        = string
}
