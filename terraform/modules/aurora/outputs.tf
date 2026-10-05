output "cluster_arn" {
  value = aws_rds_cluster.custody_ledger.arn
}

output "endpoint" {
  value = aws_rds_cluster.custody_ledger.endpoint
}

output "reader_endpoint" {
  value = aws_rds_cluster.custody_ledger.reader_endpoint
}

output "security_group_id" {
  value = aws_security_group.custody_ledger.id
}
