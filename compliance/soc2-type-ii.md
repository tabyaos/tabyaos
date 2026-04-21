# SOC 2 Type II — TabyaOS Node-Level Control Overlay

**Trust Service Criteria scope:** CC6 (Logical & Physical Access), CC7 (System Operations), CC8 (Change Management)

---

## CC6 — Logical and Physical Access Controls

| TSC | Point of Focus | Implementation | Ansible Role |
|-----|---------------|---------------|--------------|
| CC6.1 | Logical access security measures | SSH hardened (CIS 5.2); PAM lockout; umask 027 | `cis-l2` (5_access) |
| CC6.1 | Access enforcement via SELinux | SELinux enforcing, targeted policy | `cis-l2` (1_filesystem) |
| CC6.1 | No SSH — SSM Session Manager only | sshd stopped/disabled; port 22 blocked | `ssm-only-access` |
| CC6.2 | Prior authentication logged | pam_lastlog showing failed logins | `soc2-cc6-cc7-cc8` |
| CC6.3 | Access review supported | Human-readable account report via Ansible task | `soc2-cc6-cc7-cc8` |
| CC6.6 | Restrictions on inbound traffic | Unnecessary network protocols blocked (modprobe); unused services absent | `cis-l2` (2, 3) |
| CC6.7 | Transmission encryption | kubelet TLS min 1.2, approved cipher suites only | `cis-k8s-worker` |
| CC6.8 | Malware / unauthorized software prevention | AIDE file integrity monitoring + SELinux MAC | `aide`, `cis-l2` |

## CC7 — System Operations

| TSC | Point of Focus | Implementation | Ansible Role |
|-----|---------------|---------------|--------------|
| CC7.1 | System monitoring infrastructure | auditd enabled, rsyslog configured | `cis-l2` (4_logging) |
| CC7.2 | Anomaly detection | auditd SOC2 rules (shell exec, kubectl, aws CLI) | `soc2-cc6-cc7-cc8` |
| CC7.3 | Incident response data captured | /var/log protected; audit log retention 52 weeks | `cis-l2`, `auditd-pci` |
| CC7.4 | Security event logging | authpriv logged to /var/log/secure via rsyslog | `soc2-cc6-cc7-cc8` |

## CC8 — Change Management

| TSC | Point of Focus | Implementation | Ansible Role |
|-----|---------------|---------------|--------------|
| CC8.1 | Change management process | Immutable AMI: all changes via Cosign-signed Packer build in GitHub Actions | `soc2-cc6-cc7-cc8` |
| CC8.1 | Change authorisation | Git commit history + GitHub Actions audit trail | CI/CD |
| CC8.1 | Rollback capability | Previous AMI ID retained in launch template; swap node group to roll back | AMI versioning |

---

## Evidence collection

For a SOC 2 Type II audit, collect the following evidence per node:

| Evidence | Location | How to collect |
|----------|----------|---------------|
| Hardened AMI build log | GitHub Actions run | Download `packer-output.txt` artifact |
| Cosign SBOM signature bundle | GitHub Release assets | `cosign verify-blob ...` |
| kube-bench results | `tests/kube-bench/baseline/` | `run-node.sh --json` |
| auditd rule set | `/etc/audit/rules.d/` | `auditctl -l` on node via SSM |
| SELinux status | Node runtime | `getenforce` via SSM |
| AIDE last check | `/var/log/aide/aide.log` | Read via SSM |
| SSH config | `/etc/ssh/sshd_config` | Confirm sshd is inactive |
| Chrony status | Node runtime | `chronyc tracking` via SSM |

Each control maps to a machine-readable entry in [control-mappings.yaml](control-mappings.yaml).
