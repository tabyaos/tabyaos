# TabyaOS — top-level task runner
# Install: https://just.systems  |  winget install Casey.Just  |  brew install just
#
# Windows PATH note: after installing kind/QEMU open a NEW terminal, or run:
#   refreshenv  (if scoop/choco installed)
#   — or just close and reopen your terminal.

packer_dir  := "packer/al2023"
ansible_dir := "ansible"
tests_dir   := "tests"

# Detect OS for platform-specific targets
os_type := if os_family() == "windows" { "windows" } else { "unix" }

# ─────────────────────────────────────────────────────────────────────────────
# Formatting & validation
# ─────────────────────────────────────────────────────────────────────────────

# Auto-format all Packer HCL files (writes in place)
fmt:
    packer fmt -recursive packer/

# Check formatting without writing (exits non-zero if any file needs changes)
fmt-check:
    packer fmt -recursive -check packer/

# Validate the al2023 configuration (amazon-ebs + qemu sources)
validate:
    packer init {{packer_dir}}
    packer validate \
        -var-file={{packer_dir}}/vars/al2023.auto.pkrvars.hcl \
        {{packer_dir}}

# ─────────────────────────────────────────────────────────────────────────────
# Building AMIs (AWS)
# ─────────────────────────────────────────────────────────────────────────────

# Build both architectures (requires AWS credentials in environment)
build: _init
    packer build \
        -only='amazon-ebs.*' \
        -var-file={{packer_dir}}/vars/al2023.auto.pkrvars.hcl \
        {{packer_dir}}

# Build x86_64 only
build-x86:
    packer init {{packer_dir}}
    packer build \
        -only='amazon-ebs.al2023-x86_64' \
        -var-file={{packer_dir}}/vars/al2023.auto.pkrvars.hcl \
        {{packer_dir}}

# Build arm64 only
build-arm64:
    packer init {{packer_dir}}
    packer build \
        -only='amazon-ebs.al2023-arm64' \
        -var-file={{packer_dir}}/vars/al2023.auto.pkrvars.hcl \
        {{packer_dir}}

# Build with a specific EKS version  (e.g.  just build-eks-version 1.32)
build-eks-version version:
    packer init {{packer_dir}}
    packer build \
        -only='amazon-ebs.*' \
        -var eks_version={{version}} \
        -var-file={{packer_dir}}/vars/al2023.auto.pkrvars.hcl \
        {{packer_dir}}

# ─────────────────────────────────────────────────────────────────────────────
# Building QCOW2 (local QEMU — no AWS required)
# ─────────────────────────────────────────────────────────────────────────────

# Build a local QCOW2 image from the AL2023 KVM cloud image.
# Output: output/al2023-qcow2/tabyaos-al2023-x86_64-<timestamp>.qcow2
# Windows: QEMU must be in PATH (C:\Program Files\QEMU — added after install).
# For hardware acceleration on Windows 11:
#   1. Enable Windows Hypervisor Platform in Windows Features
#   2. Add  qemu_accelerator = "whpx"  to packer/al2023/vars/al2023.auto.pkrvars.hcl
build-qemu:
    packer init {{packer_dir}}
    packer build \
        -only='qemu.al2023-qcow2' \
        -var-file={{packer_dir}}/vars/al2023.auto.pkrvars.hcl \
        {{packer_dir}}

# Build QCOW2 without hardware acceleration (slower but works everywhere)
build-qemu-tcg:
    packer init {{packer_dir}}
    packer build \
        -only='qemu.al2023-qcow2' \
        -var qemu_accelerator=tcg \
        -var-file={{packer_dir}}/vars/al2023.auto.pkrvars.hcl \
        {{packer_dir}}

# Boot the latest built QCOW2 for interactive inspection.
# SSH access:  ssh -p 12222 ec2-user@localhost
# Serial log:  tail -f /tmp/tabyaos-qemu-serial.log
boot-qemu:
    #!/usr/bin/env bash
    set -euo pipefail
    QCOW2=$(ls -t output/al2023-qcow2/*.qcow2 2>/dev/null | head -1)
    if [[ -z "${QCOW2}" ]]; then
      echo "No QCOW2 found in output/al2023-qcow2/. Run: just build-qemu"
      exit 1
    fi
    echo "Booting: ${QCOW2}"
    echo "SSH:     ssh -p 12222 ec2-user@localhost"
    echo "Stop:    Ctrl-A X  (in serial console)"
    qemu-system-x86_64 \
      -m 2048 -smp 2 \
      -machine q35,accel=whpx:kvm:hvf:tcg \
      -drive "file=${QCOW2},format=qcow2,if=virtio" \
      -device virtio-rng-pci \
      -netdev "user,id=net0,hostfwd=tcp::12222-:22" \
      -device "virtio-net-pci,netdev=net0" \
      -serial "file:/tmp/tabyaos-qemu-serial.log" \
      -nographic

# ─────────────────────────────────────────────────────────────────────────────
# Cleanup
# ─────────────────────────────────────────────────────────────────────────────

# Remove Packer plugin cache and QCOW2 output
clean:
    rm -rf packer/al2023/.packer.d
    rm -rf output/

# Remove all local Packer caches across the repo
clean-all:
    find packer -name '.packer.d' -type d -exec rm -rf {} + 2>/dev/null || true
    rm -rf output/

# ─────────────────────────────────────────────────────────────────────────────
# Ansible
# ─────────────────────────────────────────────────────────────────────────────

# Lint all Ansible roles
ansible-lint:
    ansible-lint {{ansible_dir}}/

# Dry-run the full harden playbook against an inventory
ansible-check inventory:
    ansible-playbook {{ansible_dir}}/playbooks/harden.yml \
        -i {{inventory}} \
        --check --diff

# Apply full hardening (all controls)
harden inventory:
    ansible-playbook {{ansible_dir}}/playbooks/harden.yml \
        -i {{inventory}}

# Apply CIS L2 + K8s only
harden-cis inventory:
    ansible-playbook {{ansible_dir}}/playbooks/harden.yml \
        -i {{inventory}} \
        -e tabyaos_profile=cis_only

# Apply PCI-DSS full stack
harden-pci inventory:
    ansible-playbook {{ansible_dir}}/playbooks/harden.yml \
        -i {{inventory}} \
        -e tabyaos_profile=pci_dss

# ─────────────────────────────────────────────────────────────────────────────
# Molecule (Layer 1 tests — Docker, role-level)
# ─────────────────────────────────────────────────────────────────────────────

# Build the molecule Docker runner image (required on Windows; one-time setup).
build-molecule-runner:
    docker build \
        -f ci/molecule-runner.dockerfile \
        -t tabyaos/molecule-runner:latest \
        ci/

# Run all molecule scenarios sequentially via Docker runner (Windows-safe, avoids Docker network conflicts).
# Produces a PASS/FAIL summary for each role.
test-molecule:
    MSYS_NO_PATHCONV=1 docker run --rm \
        -v //var/run/docker.sock:/var/run/docker.sock \
        -v "$(pwd):/project" \
        -w /project \
        tabyaos/molecule-runner:latest \
        "bash /project/ci/run-molecule-all.sh"

# Run molecule for a single role (e.g.  just test-molecule-role cis-l2)
test-molecule-role role:
    #!/usr/bin/env bash
    set -euo pipefail
    ROLE_DIR="ansible/roles/{{role}}"
    [ -f "${ROLE_DIR}/molecule/default/molecule.yml" ] || \
      { echo "No molecule scenario found at ${ROLE_DIR}/molecule/default/"; exit 1; }
    if python3 -c "import fcntl" 2>/dev/null; then
      cd "${ROLE_DIR}" && molecule test
    else
      docker run --rm \
        -v "$(pwd):/project" \
        -v /var/run/docker.sock:/var/run/docker.sock \
        tabyaos/molecule-runner:latest \
        "cd ansible/roles/{{role}} && molecule test"
    fi

# ─────────────────────────────────────────────────────────────────────────────
# kind (Layer 3 tests — local K8s, no AWS)
# ─────────────────────────────────────────────────────────────────────────────

# Run the full kind smoke suite: cluster creation, kube-bench, workload smoke.
test-kind:
    chmod +x {{tests_dir}}/smoke/kind/run-kind-smoke.sh
    {{tests_dir}}/smoke/kind/run-kind-smoke.sh

# Keep the kind cluster alive after test (useful for debugging)
test-kind-keep:
    chmod +x {{tests_dir}}/smoke/kind/run-kind-smoke.sh
    {{tests_dir}}/smoke/kind/run-kind-smoke.sh --keep-cluster

# Delete the kind test cluster if it exists
kind-clean:
    kind delete cluster --name tabyaos-smoke 2>/dev/null || true

# ─────────────────────────────────────────────────────────────────────────────
# kube-bench & EKS smoke (Layer 4 — requires AWS)
# ─────────────────────────────────────────────────────────────────────────────

# Run kube-bench on a node (local binary or Docker fallback)
kube-bench:
    chmod +x {{tests_dir}}/kube-bench/run-node.sh
    {{tests_dir}}/kube-bench/run-node.sh --json

# Run kube-bench via SSM on a specific instance
kube-bench-ssm instance_id:
    {{tests_dir}}/kube-bench/run-node.sh --ssm {{instance_id}} --json

# Compare kube-bench before/after
kube-bench-diff before after:
    {{tests_dir}}/kube-bench/compare-baseline.sh {{before}} {{after}}

# Run smoke test against current kubeconfig cluster
smoke:
    chmod +x {{tests_dir}}/smoke/smoke-test.sh
    {{tests_dir}}/smoke/smoke-test.sh

# ─────────────────────────────────────────────────────────────────────────────
# Compliance
# ─────────────────────────────────────────────────────────────────────────────

# Validate control-mappings.yaml is well-formed YAML
validate-mappings:
    python3 -c "import yaml; yaml.safe_load(open('compliance/control-mappings.yaml'))" && echo "OK"

# List all controls for a given framework  (e.g.  just controls PCI_DSS_v4.0)
controls framework:
    python3 -c "
import yaml
data = yaml.safe_load(open('compliance/control-mappings.yaml'))
for c in data['controls']:
    if '{{framework}}' in c.get('frameworks', {}):
        reqs = c['frameworks']['{{framework}}']
        print(f\"{c['id']}: {c['title']} — {reqs}\")
"

# Generate compliance documentation from control-mappings.yaml
# Outputs: compliance/generated/by-framework/, by-role/, coverage-summary.md
gen-docs:
    python3 scripts/gen-compliance-docs.py \
        --mappings compliance/control-mappings.yaml \
        --output-dir compliance/generated

# ─────────────────────────────────────────────────────────────────────────────
# Private helpers
# ─────────────────────────────────────────────────────────────────────────────

_init:
    packer init {{packer_dir}}

_pull-amazonlinux:
    docker pull amazonlinux:2023

# ─────────────────────────────────────────────────────────────────────────────
# Meta
# ─────────────────────────────────────────────────────────────────────────────

# List all available targets
list:
    @just --list
