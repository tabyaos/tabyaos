# tabya-attest

Compliance evidence CLI for TabyaOS-hardened Kubernetes worker nodes.

## What it does

`tabya-attest` runs kube-bench and InSpec against a worker node, collects the results, and produces a Cosign-signed evidence bundle. The bundle can be handed to a QSA or BDDK auditor without requiring access to AWS or any cloud control plane.

## How it differs from running kube-bench manually

| Manual kube-bench | tabya-attest |
|---|---|
| Raw JSON output, no signing | Cosign-signed manifest over all artifacts |
| No InSpec integration | Combines kube-bench + InSpec in one bundle |
| Manual per-audit run | Designed for CI/CD pipeline integration |
| No control-mapping link | (Planned) Links results to control-mappings.yaml entries |

## Planned features

- [ ] kube-bench runner with structured JSON output
- [ ] InSpec runner with TabyaOS baseline profile
- [ ] Cosign keyless signing (OIDC via GitHub Actions)
- [ ] Cosign key-based signing (for air-gapped / on-prem environments)
- [ ] Evidence bundle: manifest + signatures + control-mapping CSV
- [ ] `attest verify` subcommand — offline bundle verification
- [ ] Turkish-language audit report template output

## Status

**Scaffold only.** The CLI structure and API are defined; implementations are stubbed with `panic("not implemented")`. The first working implementation will be tracked in the main TabyaOS milestone board.

## Build

```bash
make build   # requires Go 1.22+
make test
make lint    # requires golangci-lint
```

## Usage (once implemented)

```bash
# Run on a node and write bundle to ./evidence/
tabya-attest attest --output ./evidence/

# Verify a previously generated bundle
tabya-attest verify --bundle ./evidence/cosign.bundle

# Print version
tabya-attest version
```

## License

Business Source License 1.1 — same as TabyaOS core. See [LICENSE](../LICENSE).
