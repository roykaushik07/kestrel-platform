output "internal_zone_id" {
  value = aws_route53_zone.internal.zone_id
}

output "api_hostname" {
  value = cloudflare_record.api.name
}

output "ops_hostname" {
  value = cloudflare_record.ops.name
}
