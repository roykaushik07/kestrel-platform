locals {
  services = {
    dispatch = {
      namespace = "kestrel-dispatch"
      policies  = [var.mission_events_publish_policy_arn]
    }
    compliance = {
      namespace = "kestrel-compliance"
      policies  = [var.custody_intake_consume_policy_arn]
    }
    telemetry = {
      namespace = "kestrel-telemetry"
      policies  = []
    }
  }
}

data "aws_iam_policy_document" "irsa" {
  for_each = local.services

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${var.oidc_provider_host}:sub"
      values   = ["system:serviceaccount:${each.value.namespace}:kestrel-${each.key}"]
    }
  }
}

resource "aws_iam_role" "service" {
  for_each = local.services

  name               = "kestrel-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.irsa[each.key].json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "service" {
  for_each = {
    for pair in flatten([
      for svc, cfg in local.services : [
        for arn in cfg.policies : { key = "${svc}-${basename(arn)}", svc = svc, arn = arn }
      ]
    ]) : pair.key => pair
  }

  role       = aws_iam_role.service[each.value.svc].name
  policy_arn = each.value.arn
}

# telemetry reads/writes Kafka through MSK IAM auth.
data "aws_iam_policy_document" "telemetry_msk" {
  statement {
    actions   = ["kafka-cluster:Connect", "kafka-cluster:ReadData", "kafka-cluster:WriteData", "kafka-cluster:DescribeTopic"]
    resources = ["arn:aws:kafka:eu-west-1:381492650173:*/kestrel-prod/*"]
  }
}

resource "aws_iam_role_policy" "telemetry_msk" {
  name   = "msk-access"
  role   = aws_iam_role.service["telemetry"].id
  policy = data.aws_iam_policy_document.telemetry_msk.json
}
