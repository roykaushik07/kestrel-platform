variable "kms_key_id" {
  description = "KMS key (alias or ARN) used for SNS/SQS server-side encryption."
  type        = string
  default     = "alias/aws/sqs"
}

variable "tags" {
  type    = map(string)
  default = {}
}
