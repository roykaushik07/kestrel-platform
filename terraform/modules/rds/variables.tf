variable "vpc_id" {
  type = string
}

variable "data_subnet_ids" {
  type = list(string)
}

variable "allowed_security_group_ids" {
  description = "Security groups (EKS nodes) allowed to connect on 5432."
  type        = list(string)
}

variable "master_password" {
  description = "Initial master password. Rotated by Secrets Manager after first apply."
  type        = string
  sensitive   = true
}

variable "tags" {
  type    = map(string)
  default = {}
}
