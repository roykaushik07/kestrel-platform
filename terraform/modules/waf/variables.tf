variable "name" {
  type    = string
  default = "kestrel-edge"
}

variable "rate_limit_per_5min" {
  type    = number
  default = 2000
}
