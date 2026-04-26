# Show HN Draft — TabyaOS

**Title:** Show HN: TabyaOS – Hardened Amazon Linux 2023 for Kubernetes worker nodes

---

TabyaOS is an open-source hardened OS image for Kubernetes worker nodes, pre-configured to pass CIS Level 2, PCI-DSS v4.0, and SOC 2 Type II audits out of the box.

The problem it solves: getting worker-node compliance evidence for a regulated K8s cluster is 40+ hours of manual work per audit cycle. TabyaOS ships the controls pre-applied and audit-traceable, so the node side of the audit is already done.

What's in the v0.1.0-alpha release:
- 11 Ansible hardening roles (AL2023, Debian 12, RHEL 9), all Molecule-tested (converge + idempotence + verify)
- Every control references its framework requirement in a comment (CIS AL2023 5.2.3, PCI-DSS v4.0 Req 10.2.1, etc.)
- Machine-readable compliance mapping across 6 frameworks (48 controls)
- Packer HCL2 builds for AMI (EKS), QCOW2 (KVM), and ISO
- Cosign-signed releases with CycloneDX SBOMs

Target: fintech, card-issuing, and BaaS platforms running Kubernetes who need auditable compliance evidence.

GitHub: https://github.com/tabyaos/tabyaos

---

## Refinement notes (pre-launch checklist)

- [ ] Add actual kube-bench PASS % once Phase D is complete
- [ ] Add 1-2 sentences on what makes it different from aws/bottlerocket or chainguard
- [ ] Link to tabya.io docs when live
- [ ] Mention community: issues/PRs welcome, BSL 1.1 → Apache 2.0 after 4 years
