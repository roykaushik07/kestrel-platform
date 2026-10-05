resource "aws_db_subnet_group" "dispatch" {
  name       = "kestrel-dispatch-prod"
  subnet_ids = var.data_subnet_ids
  tags       = var.tags
}

resource "aws_security_group" "dispatch_db" {
  name_prefix = "kestrel-dispatch-db-"
  description = "Postgres access for kestrel-dispatch"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
  }

  tags = var.tags
}

resource "aws_db_parameter_group" "dispatch" {
  name_prefix = "kestrel-dispatch-pg16-"
  family      = "postgres16"

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "500"
  }

  tags = var.tags
}

resource "aws_db_instance" "dispatch" {
  identifier                = "kestrel-dispatch-prod"
  engine                    = "postgres"
  engine_version            = "16.4"
  instance_class            = "db.r6g.large"
  allocated_storage         = 200
  max_allocated_storage     = 1000
  storage_type              = "gp3"
  storage_encrypted         = true
  db_name                   = "dispatch"
  username                  = "dispatch_admin"
  password                  = var.master_password
  multi_az                  = true
  db_subnet_group_name      = aws_db_subnet_group.dispatch.name
  vpc_security_group_ids    = [aws_security_group.dispatch_db.id]
  parameter_group_name      = aws_db_parameter_group.dispatch.name
  backup_retention_period   = 14
  backup_window             = "02:00-03:00"
  maintenance_window        = "sun:03:30-sun:04:30"
  deletion_protection       = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "kestrel-dispatch-prod-final"

  performance_insights_enabled = true
  monitoring_interval          = 60
  monitoring_role_arn          = aws_iam_role.rds_monitoring.arn
  auto_minor_version_upgrade   = true
  copy_tags_to_snapshot        = true

  tags = merge(var.tags, { Service = "kestrel-dispatch" })
}

data "aws_iam_policy_document" "rds_monitoring" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "rds_monitoring" {
  name_prefix        = "kestrel-dispatch-rds-mon-"
  assume_role_policy = data.aws_iam_policy_document.rds_monitoring.json
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
