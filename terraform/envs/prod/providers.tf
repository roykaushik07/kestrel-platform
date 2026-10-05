terraform {
  required_version = ">= 1.8.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.70"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.40"
    }
    kafka = {
      source  = "Mongey/kafka"
      version = "~> 0.8"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region              = "eu-west-1"
  allowed_account_ids = ["381492650173"]

  default_tags {
    tags = local.tags
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "kafka" {
  bootstrap_servers = split(",", module.msk.bootstrap_brokers_iam)
  tls_enabled       = true
  sasl_mechanism    = "aws-iam"
  sasl_aws_region   = "eu-west-1"
}
