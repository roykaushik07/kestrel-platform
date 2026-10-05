output "github_terraform_role_arn" {
  value = aws_iam_role.github_terraform.arn
}

output "github_plan_role_arn" {
  value = aws_iam_role.github_plan.arn
}

output "service_role_arns" {
  value = { for k, r in aws_iam_role.service : k => r.arn }
}
