output "cluster_name" {
  value = module.eks.cluster_name
}

output "service_role_arns" {
  description = "IRSA role ARNs, annotated onto service accounts by the Helm charts."
  value       = module.iam.service_role_arns
}

output "github_terraform_role_arn" {
  value = module.iam.github_terraform_role_arn
}

output "github_plan_role_arn" {
  value = module.iam.github_plan_role_arn
}

output "msk_bootstrap_brokers" {
  value = module.msk.bootstrap_brokers_iam
}

output "custody_ledger_endpoint" {
  value = module.aurora.endpoint
}

output "waf_web_acl_arn" {
  value = module.waf.web_acl_arn
}
