output "instance_id" {
  value = aws_db_instance.dispatch.id
}

output "instance_arn" {
  value = aws_db_instance.dispatch.arn
}

output "address" {
  value = aws_db_instance.dispatch.address
}

output "security_group_id" {
  value = aws_security_group.dispatch_db.id
}
