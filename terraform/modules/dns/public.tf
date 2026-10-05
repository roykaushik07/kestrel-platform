# Public records live in Cloudflare.
#
# NOTE: edge.kestrel-air.net is deliberately not declared here. external-dns
# creates it from the kestrel-gateway Ingress, so the api CNAME below only
# points at a name that is owned by the cluster.

resource "cloudflare_record" "api" {
  zone_id = var.cloudflare_zone_id
  name    = "api.kestrel-air.net"
  content = "edge.kestrel-air.net"
  type    = "CNAME"
  proxied = true
}

resource "cloudflare_record" "ops" {
  zone_id = var.cloudflare_zone_id
  name    = "ops.kestrel-air.net"
  content = "cname.vercel-dns.com"
  type    = "CNAME"
  proxied = false
}
