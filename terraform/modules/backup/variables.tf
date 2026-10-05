variable "resource_arns" {
  description = "ARNs of the databases to include in the daily backup plan."
  type        = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}
