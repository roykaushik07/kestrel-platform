locals {
  cluster_name = "kestrel-prod"
  azs          = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]

  tags = {
    Project   = "kestrel"
    Env       = "prod"
    ManagedBy = "terraform"
    Repo      = "roykaushik07/kestrel-platform"
  }
}

module "network" {
  source     = "../../modules/network"
  name       = local.cluster_name
  azs        = local.azs
  cidr_block = "10.40.0.0/16"
  tags       = local.tags
}

module "eks" {
  source             = "../../modules/eks"
  cluster_name       = local.cluster_name
  vpc_id             = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids
  tags               = local.tags
}

module "rds" {
  source                     = "../../modules/rds"
  vpc_id                     = module.network.vpc_id
  data_subnet_ids            = module.network.data_subnet_ids
  allowed_security_group_ids = [module.eks.cluster_security_group_id]
  master_password            = var.dispatch_db_password
  tags                       = local.tags
}

module "aurora" {
  source                     = "../../modules/aurora"
  vpc_id                     = module.network.vpc_id
  data_subnet_ids            = module.network.data_subnet_ids
  allowed_security_group_ids = [module.eks.cluster_security_group_id]
  master_password            = var.custody_ledger_password
  tags                       = local.tags
}

module "msk" {
  source                     = "../../modules/msk"
  cluster_name               = local.cluster_name
  vpc_id                     = module.network.vpc_id
  data_subnet_ids            = module.network.data_subnet_ids
  allowed_security_group_ids = [module.eks.cluster_security_group_id]
  tags                       = local.tags
}

module "messaging" {
  source = "../../modules/messaging"
  tags   = local.tags
}

module "dns" {
  source             = "../../modules/dns"
  cloudflare_zone_id = var.cloudflare_zone_id
  vpc_id             = module.network.vpc_id
}

module "iam" {
  source                            = "../../modules/iam"
  oidc_provider_arn                 = module.eks.oidc_provider_arn
  oidc_provider_host                = module.eks.oidc_provider_host
  mission_events_publish_policy_arn = module.messaging.publish_policy_arn
  custody_intake_consume_policy_arn = module.messaging.consume_policy_arn
  tags                              = local.tags
}

module "observability" {
  source                  = "../../modules/observability"
  cluster_name            = local.cluster_name
  dispatch_db_instance_id = module.rds.instance_id
  alert_email             = var.alert_email
  tags                    = local.tags
}

module "ecr_cache" {
  source                      = "../../modules/ecr_cache"
  ghcr_credentials_secret_arn = var.ghcr_credentials_secret_arn
}

module "waf" {
  source = "../../modules/waf"
}

module "backup" {
  source        = "../../modules/backup"
  resource_arns = [module.rds.instance_arn, module.aurora.cluster_arn]
  tags          = local.tags
}
