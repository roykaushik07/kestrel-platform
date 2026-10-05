resource "aws_sns_topic" "alerts" {
  name = "${var.cluster_name}-alerts"
  tags = var.tags
}

resource "aws_sns_topic_subscription" "alerts_email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_log_group" "cluster" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 90
  tags              = var.tags
}

resource "aws_cloudwatch_log_group" "application" {
  name              = "/kestrel/${var.cluster_name}/application"
  retention_in_days = 30
  tags              = var.tags
}
