data "aws_iam_policy_document" "custody_intake_from_sns" {
  statement {
    sid       = "AllowMissionEventsPublish"
    actions   = ["sqs:SendMessage"]
    resources = [aws_sqs_queue.custody_intake.arn]

    principals {
      type        = "Service"
      identifiers = ["sns.amazonaws.com"]
    }

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_sns_topic.mission_events.arn]
    }
  }
}

resource "aws_sqs_queue_policy" "custody_intake" {
  queue_url = aws_sqs_queue.custody_intake.id
  policy    = data.aws_iam_policy_document.custody_intake_from_sns.json
}

data "aws_iam_policy_document" "mission_events_publish" {
  statement {
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.mission_events.arn]
  }
}

resource "aws_iam_policy" "mission_events_publish" {
  name   = "kestrel-mission-events-publish"
  policy = data.aws_iam_policy_document.mission_events_publish.json
  tags   = var.tags
}

data "aws_iam_policy_document" "custody_intake_consume" {
  statement {
    actions = [
      "sqs:ReceiveMessage",
      "sqs:DeleteMessage",
      "sqs:ChangeMessageVisibility",
      "sqs:GetQueueAttributes",
    ]
    resources = [aws_sqs_queue.custody_intake.arn]
  }
}

resource "aws_iam_policy" "custody_intake_consume" {
  name   = "kestrel-custody-intake-consume"
  policy = data.aws_iam_policy_document.custody_intake_consume.json
  tags   = var.tags
}
