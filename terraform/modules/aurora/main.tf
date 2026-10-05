resource "aws_db_subnet_group" "custody_ledger" {
  name       = "kestrel-custody-ledger"
  subnet_ids = var.data_subnet_ids
  tags       = var.tags
}

resource "aws_security_group" "custody_ledger" {
  name_prefix = "kestrel-custody-ledger-"
  description = "Aurora access for kestrel-compliance"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
  }

  tags = var.tags
}

resource "aws_kms_key" "custody_ledger" {
  description             = "Encryption key for the custody ledger Aurora cluster"
  enable_key_rotation     = true
  deletion_window_in_days = 30
  tags                    = var.tags
}

resource "aws_rds_cluster" "custody_ledger" {
  cluster_identifier        = "kestrel-custody-ledger"
  engine                    = "aurora-postgresql"
  engine_version            = "16.4"
  database_name             = "custody"
  master_username           = "ledger_admin"
  master_password           = var.master_password
  db_subnet_group_name      = aws_db_subnet_group.custody_ledger.name
  vpc_security_group_ids    = [aws_security_group.custody_ledger.id]
  storage_encrypted         = true
  kms_key_id                = aws_kms_key.custody_ledger.arn
  backup_retention_period   = 35
  preferred_backup_window   = "01:00-02:00"
  deletion_protection       = true
  copy_tags_to_snapshot     = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "kestrel-custody-ledger-final"

  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = merge(var.tags, { Service = "kestrel-compliance", DataClass = "chain-of-custody" })
}

resource "aws_rds_cluster_instance" "custody_ledger" {
  count                        = var.instance_count
  identifier                   = "kestrel-custody-ledger-${count.index}"
  cluster_identifier           = aws_rds_cluster.custody_ledger.id
  instance_class               = "db.r6g.large"
  engine                       = aws_rds_cluster.custody_ledger.engine
  engine_version               = aws_rds_cluster.custody_ledger.engine_version
  performance_insights_enabled = true
  tags                         = var.tags
}
