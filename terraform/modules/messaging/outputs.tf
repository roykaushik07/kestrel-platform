output "mission_events_topic_arn" {
  value = aws_sns_topic.mission_events.arn
}

output "custody_intake_queue_arn" {
  value = aws_sqs_queue.custody_intake.arn
}

output "custody_intake_queue_url" {
  value = aws_sqs_queue.custody_intake.url
}

output "publish_policy_arn" {
  value = aws_iam_policy.mission_events_publish.arn
}

output "consume_policy_arn" {
  value = aws_iam_policy.custody_intake_consume.arn
}
