resource "aws_route53_zone" "internal" {
  name    = "kestrel-air.net"
  comment = "Split-horizon private zone for in-VPC lookups"

  vpc {
    vpc_id = var.vpc_id
  }
}

# Drones talk MQTT to IoT Core; in-VPC tooling uses this alias so it does not
# need to know the account-specific endpoint hostname.
resource "aws_route53_record" "mqtt" {
  zone_id = aws_route53_zone.internal.zone_id
  name    = "mqtt.kestrel-air.net"
  type    = "CNAME"
  ttl     = 300
  records = ["a3k9x2m7qvw1zp-ats.iot.eu-west-1.amazonaws.com"]
}
