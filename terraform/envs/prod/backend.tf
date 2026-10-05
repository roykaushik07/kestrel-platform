terraform {
  backend "s3" {
    bucket         = "kestrel-tfstate-381492650173"
    key            = "prod/platform.tfstate"
    region         = "eu-west-1"
    dynamodb_table = "kestrel-tfstate-lock"
    encrypt        = true
  }
}
