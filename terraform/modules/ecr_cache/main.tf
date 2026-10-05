# Pull-through cache so nodes pull ghcr.io images through ECR instead of
# crossing the NAT for every deploy.
resource "aws_ecr_pull_through_cache_rule" "ghcr" {
  ecr_repository_prefix = "ghcr"
  upstream_registry_url = "ghcr.io"
  credential_arn        = var.ghcr_credentials_secret_arn
}

resource "aws_ecr_repository_creation_template" "ghcr" {
  prefix               = "ghcr"
  applied_for          = ["PULL_THROUGH_CACHE"]
  image_tag_mutability = "MUTABLE"

  lifecycle_policy = jsonencode({
    rules = [{
      rulePriority = 1
      description  = "Expire cached images not pulled for 60 days"
      selection = {
        tagStatus   = "any"
        countType   = "sinceImagePushed"
        countUnit   = "days"
        countNumber = 60
      }
      action = { type = "expire" }
    }]
  })
}
