variable "cluster_name" {
  type = string
}

variable "dispatch_db_instance_id" {
  type = string
}

variable "custody_dlq_name" {
  type    = string
  default = "kestrel-custody-intake-dlq"
}

variable "alert_email" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
