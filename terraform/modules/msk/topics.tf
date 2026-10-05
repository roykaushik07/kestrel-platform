# Topics are managed through the Mongey/kafka provider, which is configured
# against the bootstrap brokers in envs/prod/providers.tf.
terraform {
  required_providers {
    kafka = {
      source = "Mongey/kafka"
    }
  }
}

resource "kafka_topic" "telemetry" {
  name               = "drone.telemetry.v2"
  partitions         = 24
  replication_factor = 3

  config = {
    "cleanup.policy"   = "delete"
    "retention.ms"     = "259200000"
    "compression.type" = "zstd"
  }

  depends_on = [aws_msk_cluster.this]
}
