# kube-bench Test Harness

Runs the [kube-bench](https://github.com/aquasecurity/kube-bench) CIS Kubernetes Benchmark against TabyaOS worker nodes.

## Quick start

### In-cluster (Kubernetes Job)

```bash
kubectl apply -f tests/kube-bench/job.yaml
kubectl -n kube-system wait --for=condition=complete job/kube-bench-node --timeout=120s
kubectl -n kube-bench logs job/kube-bench-node
kubectl -n kube-system delete job/kube-bench-node
```

### Directly on a node

```bash
# Via SSH (if still enabled on baseline AMI)
ssh ec2-user@<node-ip> 'bash -s' < tests/kube-bench/run-node.sh

# Via SSM (post-hardening — no SSH)
./tests/kube-bench/run-node.sh --ssm i-0123456789abcdef0 --json

# Output lands in tests/kube-bench/baseline/
```

### Capture pre-hardening baseline

```bash
./tests/kube-bench/run-node.sh --json --output tests/kube-bench/baseline/before-hardening.json
```

### Compare before/after hardening

```bash
./tests/kube-bench/compare-baseline.sh \
  tests/kube-bench/baseline/before-hardening.json \
  tests/kube-bench/baseline/after-cis-l2.json
```

## Benchmark targets

| AMI stage | Benchmark | Target score |
|-----------|-----------|-------------|
| Baseline (no hardening) | `eks-1.4.0` | Establishes numeric baseline |
| After CIS L2 | `eks-1.4.0` | ≥ 95% PASS |
| After PCI-DSS | `eks-1.4.0` | 100% PASS on CIS K8s Worker section |

## Baseline results

Committed JSON baselines live in `baseline/`. The CI pipeline captures a new baseline snapshot on each release tag and uploads it as a build artefact.

File naming: `YYYYMMDDTHHMMSSZ-<stage>.json`
