# Changelog

All notable changes to TabyaOS are documented here.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning: [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

---

## [0.1.0-alpha] — 2026-04-22

Initial alpha release. Establishes the hardening baseline and test infrastructure.

### Added

**Packer**
- `packer/al2023/` — Packer HCL2 scaffold for Amazon Linux 2023 EKS AMI
  - Variants: `ami-eks`, `qcow2-kvm`, `iso-baremetal`, `oci`
  - Multi-arch (x86_64 + arm64) targets
  - AWS auth via environment variables (OIDC to be wired in CI)

**Ansible Hardening Roles** (9 roles, all Molecule-tested)
- `cis-l2` — CIS Amazon Linux 2023 Benchmark Level 2 full baseline
  - Filesystem module blacklists (cramfs, squashfs, udf, usb-storage)
  - `/tmp` tmpfs with noexec,nosuid,nodev
  - ASLR (`kernel.randomize_va_space=2`)
  - SELinux enforcing (targeted policy)
  - Network kernel hardening (send_redirects, accept_redirects, DCCP, SCTP disabled)
  - auditd baseline rules (identity, sudo, privileged commands, mounts, time)
  - PAM account lockout (faillock), password complexity (pwquality)
  - SSH hardening (ciphers, MACs, key-only auth)
  - Session idle timeout (TMOUT=900, readonly)
  - Warning banners (/etc/issue, /etc/issue.net)
  - File permissions hardening (/etc/passwd, /etc/shadow, /etc/cron.*)

- `auditd-pci` — PCI-DSS v4.0 audit rules (Req 10.2.x)
  - Cardholder data path auditing (`pci_chd_access`)
  - Administrative action auditing (`pci_admin`)
  - Authentication mechanism auditing (`pci_auth_config`)
  - Privileged command auditing (`pci_priv_cmd`)
  - Kernel module change auditing (`pci_modules`)
  - Network socket operation auditing (`pci_network_socket`)
  - Object create/delete auditing (`pci_object_mgmt`)
  - `write_logs=yes`, `/var/log/audit` mode 0700

- `aide` — File integrity monitoring
  - FIPSR attribute group with sha512
  - Monitors: /boot, /etc, /usr/bin, /usr/sbin, /usr/lib, /sbin, /bin
  - EKS PKI paths: /etc/eks, /var/lib/kubelet/pki
  - Excludes volatile paths: /proc, /sys, /dev, /run, /tmp, /var/log
  - Daily root cron job

- `chrony-hardened` — NTP hardening
  - Amazon Time Sync Service (169.254.169.123) + time.aws.com
  - `cmdport 0` (no remote management)
  - makestep, driftfile, maxdistance configured
  - /etc/chrony.conf mode 0640

- `fips-mode` — FIPS 140-2/3 enablement
  - `crypto-policies-scripts` + `update-crypto-policies --set FIPS`
  - `fips-mode-setup --enable` (requires reboot for kernel activation)
  - `/etc/tabyaos-release` FIPS marker

- `cis-k8s-worker` — CIS Kubernetes Benchmark v1.8 worker node section
  - Kubelet: anonymous auth disabled, read-only port 0, protectKernelDefaults
  - Kubelet: Webhook authorization, TLS 1.2 minimum, secure cipher suites
  - Kubelet: certificate rotation, event QPS, streaming timeout
  - Containerd: hardened config with SystemdCgroup=true
  - File permissions: kubelet service, kubeconfig, CA file (mode 0600)

- `pci-dss-v4` — PCI-DSS v4.0 node controls
  - `kernel.dmesg_restrict=1`, `kernel.kptr_restrict=2`
  - Bluetooth module blacklisted
  - Session timeout (TMOUT=900, readonly)
  - Sudo: no NOPASSWD, logfile=/var/log/sudo.log
  - faillock deny=10
  - chrony time sync (delegates to chrony-hardened)

- `soc2-cc6-cc7-cc8` — SOC 2 Type II CC6/CC7/CC8 overlay
  - `/etc/shadow` mode 0000
  - pam_lastlog.so for login history
  - `net.ipv4.conf.all.accept_redirects=0`
  - SOC2 CC7 audit rules (kubectl, shell exec, interpreter exec)
  - rsyslog authpriv logging to /var/log/secure
  - /etc/tabyaos-change-record (immutable-ami-replacement marker)

- `ssm-only-access` — SSM-only node access
  - sshd disabled (stopped + `enabled: false`)
  - iptables DROP TCP port 22
  - iptables rules persisted to /etc/sysconfig/iptables
  - `PasswordAuthentication no` in sshd_config
  - AccessMethod=ssm-only marker in /etc/tabyaos-release

**Molecule Test Suite**
- All 9 roles: converge + idempotence + verify passing in Docker (amazonlinux:2023)
- prepare.yml pattern: bootstraps containers without systemd
- `manage_services` variable pattern for Docker/systemd-less environments
- molecule-runner Docker image (`ci/molecule-runner.dockerfile`) with Docker-in-Docker support

**Compliance**
- `compliance/control-mappings.yaml` — 40 controls across 5 frameworks
- `scripts/gen-compliance-docs.py` — generates per-framework and per-role docs
- `compliance/generated/` — generated coverage docs

**Documentation**
- `docs/architecture.md` — build pipeline, role graph, image variants
- `docs/threat-model.md` — threat actors, mitigated attack surfaces, residual risk
- `docs/getting-started.md` — setup, quick start, role reference
- `docs/enterprise.md` — enterprise tier, attestation pack, pricing
- `docs/index.md` — MkDocs home page
- `mkdocs.yml` — MkDocs Material site configuration

**Repo Hygiene**
- `SECURITY.md` — vulnerability disclosure policy
- `CONTRIBUTING.md` — contribution guidelines
- `CODE_OF_CONDUCT.md` — community standards
- `BUILD_LOG.md` — phase-by-phase build log
- `.github/workflows/docs.yml` — GitHub Pages auto-deploy

### Changed

- AIDE config: removed deprecated `verbose=5`; replaced with `log_level=warning` + `report_level=changed_attributes` (AIDE ≥ 0.17)
- fips-mode: idempotent crypto policy check before calling `update-crypto-policies --set FIPS`

### Known Limitations

- FIPS kernel activation requires reboot — `/proc/sys/crypto/fips_enabled` only verifiable at QEMU/EKS layer
- kind smoke test (`just test-kind`) requires `kind` binary — skipped in CI until binary is added
- Debian 12 and RHEL 9 base images not yet implemented (AL2023 only)
- AWS Marketplace listing pending Delaware LLC formation

### Migration Notes

This is the initial alpha release. No migration required.

---

[Unreleased]: https://github.com/tabyaos/tabyaos/compare/v0.1.0-alpha...HEAD
[0.1.0-alpha]: https://github.com/tabyaos/tabyaos/releases/tag/v0.1.0-alpha
