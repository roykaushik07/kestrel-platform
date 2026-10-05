variable "cluster_name" {
  type    = string
  default = "kestrel-prod"
}

variable "vpc_id" {
  type = string
}

variable "data_subnet_ids" {
  type = list(string)
}

variable "allowed_security_group_ids" {
  type = list(string)
}

variable "broker_instance_type" {
  type    = string
  default = "kafka.m7g.large"
}

variable "tags" {
  type    = map(string)
  default = {}
}
