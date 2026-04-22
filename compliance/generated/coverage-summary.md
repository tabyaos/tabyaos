# TabyaOS Compliance Coverage Summary

> Generated 2026-04-22 — 40 total controls

## Coverage by Framework

| Control ID | Title | CIS_AL2023_L2 | CIS_K8s_v1.8 | PCI_DSS_v4.0 | SOC2_TSC | NIST_800-53_Rev5 |
|---|---|---|---|---|---|---|
| ACC-001 | Harden SSH configuration (ciphers, MACs, protocol, auth) | ✓ 5.2.1-5.2.23 | — | ✓ 8.2.1, 8.3.6 | ✓ CC6.1, CC6.2 | ✓ AC-17, IA-2, SC-8 |
| ACC-002 | Configure PAM password complexity and account lockout | ✓ 5.3.1, 5.3.2, 5.3.3 | — | ✓ 8.3.4, 8.3.6 | ✓ CC6.1 | ✓ AC-7, IA-5 |
| ACC-003 | Set session idle timeout | ✓ 5.4.5 | — | ✓ 8.2.8 | ✓ CC6.1 | ✓ AC-11 |
| ACC-004 | Restrict sudo â€” require password, log all sudo usage | — | — | ✓ 7.2.1, 7.2.2, 8.2.4 | ✓ CC6.1, CC6.3 | ✓ AC-6, AU-2 |
| ACC-005 | Lock inactive user accounts after inactivity period | — | — | ✓ 8.2.6, 8.2.7 | ✓ CC6.2 | ✓ AC-2 |
| ACC-006 | Set session idle timeout (PCI-DSS 900 seconds) | — | — | ✓ 8.2.8 | ✓ CC6.1 | ✓ AC-11 |
| CM-001 | Immutable AMI change management â€” all changes via signed Packer build | — | — | ✓ 6.5.1 | ✓ CC8.1 | ✓ CM-3, CM-5 |
| CM-002 | Write node metadata marker for audit trail | — | — | ✓ 6.5.1, 10.3.1 | ✓ CC8.1 | ✓ CM-3 |
| FIM-001 | AIDE file integrity monitoring | ✓ 1.3.1, 1.3.2, 1.3.3 | — | ✓ 11.3.1, 11.3.2 | ✓ CC6.8, CC7.2 | ✓ SI-7 |
| FIPS-001 | Enable FIPS 140-2/3 mode (kernel crypto + OpenSSL FIPS provider) | — | — | ✓ 4.2.1, 6.3.1 | ✓ CC6.1, CC6.7 | ✓ SC-12, SC-13, IA-7 |
| FIPS-002 | Set OS crypto policy to FIPS via update-crypto-policies | — | — | ✓ 4.2.1 | — | ✓ SC-12, SC-13 |
| FS-001 | Disable unused filesystems (cramfs, squashfs, udf, usb-storage) | ✓ 1.1.1.1, 1.1.1.2, 1.1.1.3, 1.1.1.4 | — | ✓ 2.2.1 | — | ✓ CM-7 |
| FS-002 | Secure /tmp mount with noexec,nosuid,nodev | ✓ 1.1.2.2, 1.1.2.3, 1.1.2.4 | — | ✓ 2.2.1 | — | — |
| FS-003 | Enable ASLR | ✓ 1.5.2 | — | — | — | ✓ SI-16 |
| FS-004 | Enable SELinux in enforcing mode (targeted policy) | ✓ 1.6.1.2, 1.6.1.3 | — | ✓ 2.2.1, 6.3.1 | ✓ CC6.1, CC6.8 | ✓ AC-3, AC-6 |
| K8S-001 | Disable kubelet anonymous authentication | — | ✓ 4.2.1 | ✓ 7.2.1 | — | ✓ AC-3, IA-2 |
| K8S-002 | Disable kubelet read-only port | — | ✓ 4.2.4 | ✓ 1.3.1 | — | ✓ CM-7 |
| K8S-003 | Enable kubelet protect-kernel-defaults | — | ✓ 4.2.6 | — | — | ✓ CM-6 |
| K8S-004 | Set kubelet TLS minimum version and cipher suites | — | ✓ 4.2.12 | ✓ 4.2.1 | ✓ CC6.7 | ✓ SC-8, SC-28 |
| K8S-005 | Deploy hardened containerd config (SystemdCgroup, seccomp) | — | ✓ 5.1.3, 5.2.1 | ✓ 2.2.1, 6.3.1 | — | ✓ CM-6, CM-7 |
| K8S-006 | Ensure kubelet service file permissions are 600 | — | ✓ 4.1.1 | ✓ 2.2.1 | — | ✓ AC-3 |
| K8S-007 | Set kubelet authorization mode to Webhook | — | ✓ 4.2.2 | ✓ 7.2.1 | — | ✓ AC-3, IA-2 |
| K8S-008 | Enable kubelet certificate rotation | — | ✓ 4.2.11 | ✓ 4.2.1, 6.3.1 | ✓ CC6.7 | ✓ SC-12, IA-5 |
| KERN-001 | Restrict kernel dmesg (dmesg_restrict=1) | — | — | ✓ 2.2.5 | — | ✓ CM-6, SI-3 |
| KERN-002 | Restrict kernel pointer exposure (kptr_restrict=2) | — | — | ✓ 2.2.5 | — | ✓ CM-6, SI-3 |
| KERN-003 | Disable Bluetooth kernel module | — | — | ✓ 2.2.4, 1.3.1 | — | ✓ CM-7 |
| LOG-001 | Configure auditd with retention and disk-full actions | ✓ 4.1.2.1, 4.1.2.2, 4.1.2.3, 4.1.2.4, 4.1.2.5, 4.1.2.6, 4.1.2.7 | — | ✓ 10.5.1, 10.7.1 | ✓ CC7.1, CC7.2 | ✓ AU-4, AU-5 |
| LOG-002 | Deploy CIS baseline audit rules (identity, sudo, privileged commands, mounts) | ✓ 4.1.3.1, 4.1.3.2, 4.1.3.4, 4.1.3.5, 4.1.3.7, 4.1.3.9, 4.1.3.10, 4.1.3.11, 4.1.3.12 | — | ✓ 10.2.1.1, 10.2.1.2, 10.2.1.5, 10.2.1.7 | ✓ CC7.2, CC7.3 | ✓ AU-2, AU-12 |
| LOG-003 | Deploy PCI-DSS-specific audit rules (cardholder data, authentication mechanisms) | — | — | ✓ 10.2.1.1, 10.2.1.2, 10.2.1.3, 10.2.1.4, 10.2.1.5, 10.2.1.6, 10.2.1.7, 10.2.2, 10.3.2 | ✓ CC7.2 | ✓ AU-2, AU-12, SI-4 |
| NET-001 | Disable uncommon network protocols (DCCP, SCTP, RDS, TIPC) | ✓ 3.4.1, 3.4.2, 3.4.3, 3.4.4 | — | ✓ 1.3.1 | — | ✓ CM-7 |
| NET-002 | Harden IPv4 kernel network parameters | ✓ 3.2.1, 3.2.2, 3.2.3, 3.2.4, 3.2.5, 3.2.6, 3.3.1, 3.3.2, 3.3.3 | — | ✓ 1.3.2 | — | ✓ SC-5, SC-7 |
| SOC2-001 | Protect /etc/shadow (mode 0000) | — | — | ✓ 8.2.1 | ✓ CC6.1 | ✓ AC-3, IA-5 |
| SOC2-002 | Enable login history via pam_lastlog | — | — | ✓ 10.2.1.5 | ✓ CC6.2 | ✓ AC-9, AU-14 |
| SOC2-003 | Block ICMP redirects (accept_redirects=0) | — | — | ✓ 1.3.2 | ✓ CC6.6 | ✓ SC-5, SC-7 |
| SOC2-004 | Deploy SOC2 CC7 audit rules (kubectl, shell exec, interpreter exec) | — | — | ✓ 10.2.1.1, 10.2.1.7 | ✓ CC7.2 | ✓ AU-2, AU-12, SI-4 |
| SOC2-005 | Configure rsyslog authpriv logging to /var/log/secure | — | — | ✓ 10.3.1, 10.5.1 | ✓ CC7.2 | ✓ AU-3, AU-9 |
| SSM-001 | Disable SSH â€” enforce SSM Session Manager for node access | — | — | ✓ 8.2.1, 8.2.3 | ✓ CC6.1, CC6.2 | ✓ AC-17, CM-7 |
| SSM-002 | Block TCP port 22 via iptables â€” no SSH ingress possible | — | — | ✓ 1.3.1, 8.2.1 | ✓ CC6.6 | ✓ CM-7, SC-7 |
| SVC-001 | Remove unnecessary network services | ✓ 2.2.1-2.2.21 | — | ✓ 1.3.1, 2.2.1 | ✓ CC6.6 | ✓ CM-7 |
| TIME-001 | Configure chronyd with Amazon Time Sync Service | ✓ 2.1.x | — | ✓ 10.6.1, 10.6.2, 10.6.3 | ✓ CC7.1 | ✓ AU-8 |

## Controls by Role

- **`aide`**: FIM-001
- **`auditd-pci`**: LOG-003
- **`chrony-hardened`**: TIME-001
- **`cis-k8s-worker`**: K8S-001, K8S-002, K8S-003, K8S-004, K8S-005, K8S-006, K8S-007, K8S-008
- **`cis-l2`**: ACC-001, ACC-002, ACC-003, FS-001, FS-002, FS-003, FS-004, LOG-001, LOG-002, NET-001, NET-002, SVC-001
- **`fips-mode`**: CM-002, FIPS-001, FIPS-002
- **`pci-dss-v4`**: ACC-004, ACC-005, ACC-006, KERN-001, KERN-002, KERN-003
- **`soc2-cc6-cc7-cc8`**: CM-001, SOC2-001, SOC2-002, SOC2-003, SOC2-004, SOC2-005
- **`ssm-only-access`**: SSM-001, SSM-002

## Framework Requirement Counts

- **CIS Amazon Linux 2023 Benchmark Level 2**: 14 controls covering 49 requirement IDs
- **CIS Kubernetes Benchmark v1.8**: 8 controls covering 9 requirement IDs
- **PCI-DSS v4.0**: 38 controls covering 35 requirement IDs
- **SOC 2 Trust Service Criteria**: 25 controls covering 10 requirement IDs
- **NIST SP 800-53 Rev 5**: 39 controls covering 32 requirement IDs