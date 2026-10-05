resource "aws_backup_vault" "this" {
  name = "kestrel-prod"
  tags = var.tags
}

resource "aws_backup_plan" "daily" {
  name = "kestrel-daily"

  rule {
    rule_name         = "daily-35d"
    target_vault_name = aws_backup_vault.this.name
    schedule          = "cron(0 4 * * ? *)"

    lifecycle {
      delete_after = 35
    }
  }
}

data "aws_iam_policy_document" "backup_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "backup" {
  name               = "kestrel-backup"
  assume_role_policy = data.aws_iam_policy_document.backup_assume.json
}

resource "aws_iam_role_policy_attachment" "backup" {
  role       = aws_iam_role.backup.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}

resource "aws_backup_selection" "databases" {
  name         = "databases"
  plan_id      = aws_backup_plan.daily.id
  iam_role_arn = aws_iam_role.backup.arn
  resources    = var.resource_arns
}
