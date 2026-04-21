#!/usr/bin/env bash
# TabyaOS smoke test — verifies a hardened node can run a basic workload.
# Prerequisites: kubectl configured, cluster reachable, tabyaos test AMI deployed
# as a managed node group.
#
# Usage: ./tests/smoke/smoke-test.sh [--namespace tabyaos-smoke] [--node-label <k=v>]

set -euo pipefail

NAMESPACE="${TABYAOS_SMOKE_NS:-tabyaos-smoke}"
NODE_LABEL="${TABYAOS_NODE_LABEL:-tabyaos.io/hardening-level=baseline}"
TIMEOUT=300

PASS=0; FAIL=0

pass() { echo "  PASS  $1"; ((PASS++)); }
fail() { echo "  FAIL  $1"; ((FAIL++)); }

header() { echo ""; echo "── $1 ──"; }

cleanup() {
  echo ""
  echo "── Cleanup ──"
  kubectl delete namespace "${NAMESPACE}" --ignore-not-found --timeout=60s 2>/dev/null || true
}
trap cleanup EXIT

echo "=== TabyaOS smoke test ==="
echo "Namespace  : ${NAMESPACE}"
echo "Node label : ${NODE_LABEL}"
echo ""

# ── 1. Namespace creation ──────────────────────────────────────────────────────
header "1. Namespace"
if kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -; then
  pass "Namespace ${NAMESPACE} created"
else
  fail "Namespace creation failed"
fi

# ── 2. Node availability ───────────────────────────────────────────────────────
header "2. Node availability"
NODE_COUNT=$(kubectl get nodes -l "${NODE_LABEL}" --no-headers 2>/dev/null | grep -c Ready || true)
if [[ "${NODE_COUNT}" -gt 0 ]]; then
  pass "${NODE_COUNT} node(s) with label ${NODE_LABEL} in Ready state"
else
  echo "  WARN  No nodes found with label ${NODE_LABEL} — smoke test will run on any available node"
fi

# ── 3. Deploy nginx workload ───────────────────────────────────────────────────
header "3. Nginx workload"
kubectl apply -n "${NAMESPACE}" -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: smoke-nginx
  labels:
    app: smoke-nginx
    tabyaos.io/test: "true"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: smoke-nginx
  template:
    metadata:
      labels:
        app: smoke-nginx
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 101
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: nginx
          image: nginxinc/nginx-unprivileged:alpine
          ports:
            - containerPort: 8080
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop: [ALL]
          resources:
            requests:
              cpu: 10m
              memory: 32Mi
            limits:
              cpu: 100m
              memory: 64Mi
          volumeMounts:
            - name: tmp
              mountPath: /tmp
            - name: var-cache
              mountPath: /var/cache/nginx
            - name: var-run
              mountPath: /var/run
      volumes:
        - name: tmp
          emptyDir: {}
        - name: var-cache
          emptyDir: {}
        - name: var-run
          emptyDir: {}
EOF

if kubectl -n "${NAMESPACE}" rollout status deployment/smoke-nginx --timeout="${TIMEOUT}s"; then
  pass "smoke-nginx deployment rolled out"
else
  fail "smoke-nginx deployment failed to roll out within ${TIMEOUT}s"
fi

# ── 4. HTTP response check ─────────────────────────────────────────────────────
header "4. HTTP response"
kubectl -n "${NAMESPACE}" port-forward deployment/smoke-nginx 18080:8080 &
PF_PID=$!
sleep 3

HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:18080/ 2>/dev/null || echo "000")
kill "${PF_PID}" 2>/dev/null || true

if [[ "${HTTP_CODE}" == "200" ]]; then
  pass "nginx returned HTTP 200"
else
  fail "nginx returned HTTP ${HTTP_CODE} (expected 200)"
fi

# ── 5. PCI network policy ──────────────────────────────────────────────────────
header "5. Network policy enforcement"
kubectl apply -n "${NAMESPACE}" -f - <<EOF
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: smoke-pci-isolation
  labels:
    tabyaos.io/framework: pci-dss-v4
spec:
  podSelector:
    matchLabels:
      app: smoke-nginx
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              tabyaos.io/allowed-client: "true"
      ports:
        - protocol: TCP
          port: 8080
  egress:
    - ports:
        - protocol: UDP
          port: 53
EOF

NP_COUNT=$(kubectl -n "${NAMESPACE}" get networkpolicy smoke-pci-isolation --no-headers 2>/dev/null | wc -l | tr -d ' ')
if [[ "${NP_COUNT}" -gt 0 ]]; then
  pass "PCI network policy applied"
else
  fail "PCI network policy creation failed"
fi

# ── 6. Privileged container rejection ─────────────────────────────────────────
header "6. Privileged container rejection (PSA)"
PRIV_RESULT=$(kubectl run smoke-priv-test \
  -n "${NAMESPACE}" \
  --image=busybox \
  --restart=Never \
  --dry-run=server \
  --overrides='{"spec":{"containers":[{"name":"c","image":"busybox","securityContext":{"privileged":true}}]}}' \
  2>&1 || true)

if echo "${PRIV_RESULT}" | grep -qi "forbidden\|violates\|not allowed"; then
  pass "Privileged container rejected by Pod Security Admission"
else
  fail "Privileged container was NOT rejected — check PSA labels on namespace"
fi

# ── Summary ────────────────────────────────────────────────────────────────────
echo ""
echo "=== Smoke test summary ==="
echo "PASS: ${PASS}"
echo "FAIL: ${FAIL}"
echo ""

if [[ "${FAIL}" -gt 0 ]]; then
  echo "RESULT: FAILED (${FAIL} checks failed)"
  exit 1
else
  echo "RESULT: ALL PASSED"
  exit 0
fi
