resource "aws_sns_topic" "mission_events" {
  name = "kestrel-mission-events"
}

resource "aws_sqs_queue" "custody_intake_dlq" {
  name                      = "kestrel-custody-intake-dlq"
  message_retention_seconds = 1209600
  sqs_managed_sse_enabled   = true
}

resource "aws_sqs_queue" "custody_intake" {
  name                       = "kestrel-custody-intake"
  visibility_timeout_seconds = 120
  message_retention_seconds  = 345600
  sqs_managed_sse_enabled    = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.custody_intake_dlq.arn
    maxReceiveCount     = 5
  })
}

resource "aws_sqs_queue_redrive_allow_policy" "custody_intake_dlq" {
  queue_url = aws_sqs_queue.custody_intake_dlq.id

  redrive_allow_policy = jsonencode({
    redrivePermission = "byQueue"
    sourceQueueArns   = [aws_sqs_queue.custody_intake.arn]
  })
}

resource "aws_sns_topic_subscription" "custody_from_missions" {
  topic_arn            = aws_sns_topic.mission_events.arn
  protocol             = "sqs"
  endpoint             = aws_sqs_queue.custody_intake.arn
  raw_message_delivery = true

  filter_policy = jsonencode({
    event_type = ["mission.handoff", "mission.delivered", "mission.aborted"]
  })
}
