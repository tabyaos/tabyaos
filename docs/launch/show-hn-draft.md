# Show HN Draft — TabyaOS

**Title:** Show HN: TabyaOS – hardened Kubernetes node OS for PCI-DSS/SOC 2/CIS compliance

---

Getting a K8s worker node to pass a PCI-DSS v4.0 or SOC 2 audit is roughly 40+ hours of work per audit cycle: manual control mapping, custom Ansible, evidence collection. We built TabyaOS to make the node side of that audit a solved problem.

TabyaOS is an open-source hardened OS image for Kubernetes worker nodes. v0.1.0-alpha ships today.

What's included:
- 11 Ansible hardening roles (Amazon Linux 2023, Debian 12, RHEL 9) — all Molecule-tested (converge + idempotence + verify in Docker)
- Every control is traceable to a named framework requirement in the code (`# CIS AL2023 5.2.3`, `# PCI-DSS v4.0 Req 10.2.1.1`)
- 48 controls mapped across CIS AL2023/Kubernetes, PCI-DSS v4.0, SOC 2 Type II, NIST 800-53
- Packer HCL2 for EKS AMI, QCOW2 (KVM), and ISO output formats
- Cosign-signed releases with CycloneDX SBOMs

Different from Bottlerocket or Chainguard: those are purpose-built container runtimes. TabyaOS targets teams that need to pass a real PCI QSA or SOC 2 audit on general-purpose AL2023/Debian/RHEL nodes — the controls are implemented and documented, not just a locked-down base image.

BSL 1.1 license (free for non-competing use, converts to Apache 2.0 in 4 years). Issues and PRs welcome.

https://github.com/tabyaos/tabyaos

---

## Pre-launch checklist

- [x] kube-bench baseline captured (k3d smoke test pipeline confirmed working)
- [ ] tabya.io docs site live before posting
- [ ] 1 blog post published alongside Show HN
- [ ] CNCF Security Landscape submission
