# Kestrel: expected StackPrism links (answer key)

This is the answer key for the Kestrel fixture system: seven repos that StackPrism's multi-repo linker should connect. The machine-readable twin is `expected-links.json`; the harness (`harness/src/cli.ts check kestrel`) compares real StackPrism output against it.

Pick order: `kestrel-console`, `kestrel-gateway`, `kestrel-dispatch`, `kestrel-telemetry`, `kestrel-compliance`, `kestrel-contracts`, `kestrel-platform`. All repos are owned by `roykaushik07`. Evidence is written `repo/path#Lline`, listed as [uses fact, DNS record (hosts only), exposes fact]. Tiers:

- T1: hosts that must be found.
- T2: queue, database, image and package links that must be found.
- T2-budget: real links that must be absent because the evidence file is cut by the 60-file budget.
- T3: real relations StackPrism cannot see today; must be absent.
- FP: false positives StackPrism currently draws (a "no longer drawn" result is only a note).

## T1: hosts

| Link | Reason | Evidence |
|---|---|---|
| console -> gateway `api.kestrel-air.net` | console calls the public API host, a Cloudflare record names it, the gateway ingress serves it | kestrel-console/.env.example#L2, kestrel-platform/terraform/modules/dns/public.tf#L7, kestrel-gateway/deploy/k8s/ingress.yaml#L12 |
| dispatch -> telemetry `telemetry.internal.kestrel-air.net` | dispatch calls telemetry's internal ingress host | kestrel-dispatch/.env.example#L5, kestrel-telemetry/deploy/k8s/ingress.yaml#L11 |
| telemetry -> dispatch `dispatch.internal.kestrel-air.net` | telemetry calls dispatch's internal ingress host | kestrel-telemetry/config/default.toml#L11, kestrel-dispatch/deploy/k8s/ingress.yaml#L12 |
| compliance -> dispatch `dispatch.internal.kestrel-air.net` | compliance calls dispatch's internal ingress host | kestrel-compliance/.env.example#L3, kestrel-dispatch/deploy/k8s/ingress.yaml#L12 |

## T2: queues, databases, images, packages

| Link | Reason | Evidence |
|---|---|---|
| queue dispatch -> platform `kestrel-mission-events` | SQS queue URL in env, queue declared in Terraform | kestrel-dispatch/.env.example#L2, kestrel-platform/terraform/modules/messaging/main.tf#L1 |
| queue compliance -> platform `kestrel-custody-intake` | SQS queue URL in env | kestrel-compliance/.env.example#L1, kestrel-platform/terraform/modules/messaging/main.tf#L11 |
| queue telemetry -> platform `drone.telemetry.v2` | Kafka topic from the k8s configmap (`KESTREL__KAFKA__TOPIC`) | kestrel-telemetry/deploy/k8s/configmap.yaml#L6, kestrel-platform/terraform/modules/msk/topics.tf#L11 |
| queue dispatch -> platform `drone.telemetry.v2` | Kafka topic in env | kestrel-dispatch/.env.example#L4, kestrel-platform/terraform/modules/msk/topics.tf#L11 |
| database dispatch -> platform `kestrel-dispatch-prod` | RDS instance hostname in the database URL | kestrel-dispatch/.env.example#L1, kestrel-platform/terraform/modules/rds/main.tf#L39 |
| database compliance -> platform `kestrel-custody-ledger` (known bug `aurora-cluster-endpoint`) | Aurora cluster endpoint; the RDS regex rejects the `cluster-` segment, so StackPrism misses it | kestrel-compliance/.env.example#L2, kestrel-platform/terraform/modules/aurora/main.tf#L29 |
| image platform -> gateway `ghcr.io/roykaushik07/kestrel-gateway` | platform deploys the gateway image; deduped to docker-compose (priority 90, read first) | kestrel-platform/docker-compose.yml#L39, kestrel-gateway/Dockerfile#L1 |
| image platform -> dispatch `ghcr.io/roykaushik07/kestrel-dispatch` | same, compose wins | kestrel-platform/docker-compose.yml#L48, kestrel-dispatch/Dockerfile#L1 |
| image platform -> compliance `ghcr.io/roykaushik07/kestrel-compliance` | not in compose; Helm values file is the first use | kestrel-platform/deploy/helm/values/kestrel-compliance/values.yaml#L2, kestrel-compliance/Dockerfile#L1 |
| package console -> contracts `@kestrel/contracts` | npm dependency | kestrel-console/package.json#L13, kestrel-contracts/package.json#L2 |
| package gateway -> contracts `@kestrel/contracts` | npm dependency of the nested edge-auth plugin | kestrel-gateway/plugins/edge-auth/package.json#L13, kestrel-contracts/package.json#L2 |
| package gateway -> contracts `github.com/roykaushik07/kestrel-contracts/go` | Go module requirement | kestrel-gateway/go.mod#L9, kestrel-contracts/go/go.mod#L1 |
| package dispatch -> contracts `github.com/roykaushik07/kestrel-contracts/go` | Go module requirement | kestrel-dispatch/go.mod#L10, kestrel-contracts/go/go.mod#L1 |

## T2-budget (must be absent)

| Link | Reason | Evidence |
|---|---|---|
| image platform -> telemetry `ghcr.io/roykaushik07/kestrel-telemetry` | telemetry is not in compose, and its values file is past the 60-file cut (platform selects 60 files, cut: `deploy/helm/values/kestrel-telemetry/values.yaml`) | kestrel-platform/deploy/helm/values/kestrel-telemetry/values.yaml#L2, kestrel-telemetry/Dockerfile#L1 |

## T3 (real, but must be absent)

| Link | Reason | Evidence |
|---|---|---|
| host gateway -> dispatch `kestrel-dispatch.kestrel.svc.cluster.local` | k8s Service DNS is not an exposes source | kestrel-gateway/config/routes.yaml#L4 |
| host gateway -> telemetry `kestrel-telemetry.kestrel.svc.cluster.local` | same | kestrel-gateway/config/routes.yaml#L5 |
| host gateway -> compliance `kestrel-compliance.kestrel.svc.cluster.local` | same | kestrel-gateway/config/routes.yaml#L6 |
| package telemetry -> contracts `kestrel-contracts` | Cargo has no exposes extractor; git dependency name lacks the owner | kestrel-telemetry/Cargo.toml#L25, kestrel-contracts/rust/Cargo.toml#L2 |
| package compliance -> contracts `kestrel-contracts` | PyPI name lacks the owner, so not treated as internal | kestrel-compliance/pyproject.toml#L18, kestrel-contracts/python/pyproject.toml#L6 |

## FP (currently drawn, wrong)

| Link | Reason | Evidence |
|---|---|---|
| host compliance -> gateway `api.kestrel-air.net` | the CORS allowed-origin value sits on the line after its key (`name:` / `value:`) in a k8s env list; compliance serves that origin, it does not call it | kestrel-compliance/deploy/k8s/deployment.yaml#L23, kestrel-platform/terraform/modules/dns/public.tf#L7, kestrel-gateway/deploy/k8s/ingress.yaml#L12 |

## Expected unresolved uses

- console: host `legacy-router.kestrel-air.net` (owned domain, nothing exposes it), host `o4508001.ingest.de.sentry.io` (SaaS)
- compliance: host `api.twilio.com` (SaaS)
- gateway: host `kestrel-dispatch.kestrel.svc.cluster.local` (in-cluster Service DNS)
- dispatch: host `api.altitudeangel.com` (SaaS)

Also exposed but with no consumers (no links expected): dispatch exposes `github.com/roykaushik07/kestrel-dispatch`; gateway exposes `github.com/roykaushik07/kestrel-gateway` and `@kestrel/edge-auth`.

## Known StackPrism gaps

- Aurora cluster endpoints: the RDS hostname regex rejects the `cluster-` segment, so the custody-ledger database link is missed.
- Multi-line env self-URLs: a value on the line after its key (k8s `name:`/`value:`) is read as a use, producing the compliance -> gateway false positive.
- k8s Service DNS (`*.svc.cluster.local`) is never an exposes source, so gateway -> dispatch/telemetry/compliance upstreams are unlinked.
- Cargo and PyPI package naming: no Cargo exposes extractor, and bare names (`kestrel-contracts`) lack the owner, so telemetry and compliance are not linked to contracts.
- 60-file budget: kestrel-platform has 61 candidate files and the scanner keeps the 60 highest-priority (ties in git order). `deploy/helm/values/kestrel-telemetry/values.yaml` (priority 55, last in git order) is cut, which is why the platform -> telemetry image link is absent (T2-budget).
- Python, Go and Rust source is never read; only manifests, env files, config and infra files count.
- Kafka topic keys: telemetry's `config/default.toml` `topic = "drone.telemetry.v2"` alone would be missed, since a bare `topic =` key is ignored. The link exists only because `deploy/k8s/configmap.yaml` carries `KESTREL__KAFKA__TOPIC`.

## Traps

- Same-line self URLs: kestrel-gateway/.env.example#L2 `ALLOWED_ORIGINS=https://ops.kestrel-air.net` and kestrel-console/.env.example#L1 `NEXTAUTH_URL=https://ops.kestrel-air.net` produce no fact (the key filter rejects them on the same line). Contrast with the multi-line compliance CORS false positive, where the value is on the line after its key.
- Credential redaction: kestrel-dispatch/.env.example#L1 `DATABASE_URL=postgres://admin:hunter2@kestrel-dispatch-prod...` yields a fact whose value is the RDS host/identifier only; the snippet shows `//•••@`, never the password.
- `ops.kestrel-air.net` has a Cloudflare record pointing at `cname.vercel-dns.com` (kestrel-platform/terraform/modules/dns/public.tf#L18). Nobody exposes the target, so there is no link.
- kestrel-platform/docker-compose.yml deliberately excludes the telemetry and compliance images (see its header comment), so those image links depend only on Helm values files. That is what makes the 60-file budget case bite for telemetry.
- `legacy-router.kestrel-air.net` (kestrel-console/.env.example#L3) is a decommissioned host; nothing exposes it, so it stays unresolved.
- `mqtt.kestrel-air.net` (kestrel-telemetry/config/default.toml#L2) stays unresolved: the platform private-zone record (kestrel-platform/terraform/modules/dns/private.tf#L14) points at an IoT Core endpoint nobody exposes.
- `kestrel.okta.com` and `github.com` are third-party hosts and stay unresolved.
- Platform's image self-references are intentional links (platform deploys everything), not noise.
- Each service's own deployment image (for example `ghcr.io/roykaushik07/kestrel-gateway` in gateway's deploy/k8s/deployment.yaml) is a self-reference and stays unresolved.
