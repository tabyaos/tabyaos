# CIS Amazon Linux 2023 Benchmark Level 2 — TabyaOS Implementation

All 6 sections of the CIS AL2023 Level 2 Benchmark are implemented in the `cis-l2` Ansible role.

## Coverage summary

| Section | Title | Ansible task file | Status |
|---------|-------|-------------------|--------|
| 1 | Initial Setup — Filesystem | `tasks/1_filesystem.yml` | ✅ |
| 2 | Services | `tasks/2_services.yml` | ✅ |
| 3 | Network Configuration | `tasks/3_network.yml` | ✅ |
| 4 | Logging and Auditing | `tasks/4_logging.yml` | ✅ |
| 5 | Access, Authentication and Authorization | `tasks/5_access.yml` | ✅ |
| 6 | System Maintenance | `tasks/6_maintenance.yml` | ✅ |

## Kubernetes-specific overrides

Some CIS OS controls conflict with Kubernetes operation and are intentionally overridden:

| Control | Default CIS recommendation | TabyaOS override | Reason |
|---------|---------------------------|-----------------|--------|
| 3.3.4 | Disable IP forwarding | `net.ipv4.ip_forward=1` | Required for pod-to-pod networking |
| 4.1.3.20 | Immutable audit config (`-e 2`) | Commented out | Incompatible with kubelet log rotation during node init |
| 5.2.x | SSH PermitRootLogin no | Enforced | ✅ No override needed |

All overrides are documented in `compliance/control-mappings.yaml` with justification.

## Verification

```bash
# After building and joining an EKS node, run kube-bench
just validate  # packer validate only
./tests/kube-bench/run-node.sh --json
```

Target score after CIS L2 hardening: **≥ 95% PASS** on `eks-1.4.0` benchmark.
