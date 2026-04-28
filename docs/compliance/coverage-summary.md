# TabyaOS Compliance Coverage Summary

> Generated 2026-04-28 — 74 total controls

## Coverage by Framework

| Control ID | Title | CIS_AL2023_L2 | CIS_Debian12_L2 | CIS_K8s_v1.8 | PCI_DSS_v4.0 | SOC2_TSC | NIST_800-53_Rev5 |
|---|---|---|---|---|---|---|---|
| ACC-001 | Harden SSH configuration (ciphers, MACs, protocol, auth) | ✓ 5.2.1-5.2.23 | — | — | ✓ 8.2.1, 8.3.6 | ✓ CC6.1, CC6.2 | ✓ AC-17, IA-2, SC-8 |
| ACC-002 | Configure PAM password complexity and account lockout | ✓ 5.3.1, 5.3.2, 5.3.3 | — | — | ✓ 8.3.4, 8.3.6 | ✓ CC6.1 | ✓ AC-7, IA-5 |
| ACC-003 | Set session idle timeout | ✓ 5.4.5 | — | — | ✓ 8.2.8 | ✓ CC6.1 | ✓ AC-11 |
| ACC-004 | Restrict sudo â€” require password, log all sudo usage | — | — | — | ✓ 7.2.1, 7.2.2, 8.2.4 | ✓ CC6.1, CC6.3 | ✓ AC-6, AU-2 |
| ACC-005 | Lock inactive user accounts after inactivity period | — | — | — | ✓ 8.2.6, 8.2.7 | ✓ CC6.2 | ✓ AC-2 |
| ACC-006 | Set session idle timeout (PCI-DSS 900 seconds) | — | — | — | ✓ 8.2.8 | ✓ CC6.1 | ✓ AC-11 |
| CM-001 | Immutable AMI change management â€” all changes via signed Packer build | — | — | — | ✓ 6.5.1 | ✓ CC8.1 | ✓ CM-3, CM-5 |
| CM-002 | Write node metadata marker for audit trail | — | — | — | ✓ 6.5.1, 10.3.1 | ✓ CC8.1 | ✓ CM-3 |
| DEB-001 | Disable unused filesystems (cramfs, squashfs, udf, usb-storage) â€” Debian 12 | — | ✓ 1.1.1.1, 1.1.1.2, 1.1.1.3, 1.1.1.4 | — | ✓ 2.2.1 | — | ✓ CM-7 |
| DEB-002 | Secure /tmp as tmpfs with noexec,nosuid,nodev â€” Debian 12 | — | ✓ 1.1.2 | — | ✓ 2.2.1 | — | — |
| DEB-003 | Enable ASLR (kernel.randomize_va_space=2) â€” Debian 12 | — | ✓ 1.5.2 | — | ✓ 2.2.5 | — | ✓ SI-16 |
| DEB-004 | Enable AppArmor enforcing mode â€” Debian 12 | — | ✓ 1.6.1, 1.6.2, 1.6.3 | — | ✓ 2.2.3 | — | ✓ AC-3, SI-7 |
| DEB-005 | Disable unused network protocols (DCCP, SCTP, RDS) â€” Debian 12 | — | ✓ 3.1.1, 3.1.2, 3.1.3 | — | ✓ 1.2.5 | — | ✓ CM-7, SC-7 |
| DEB-006 | Network sysctl hardening â€” send/accept redirects disabled â€” Debian 12 | — | ✓ 3.2.1, 3.2.2, 3.2.3 | — | ✓ 1.3.2, 1.3.4 | — | ✓ SC-5, SC-7 |
| DEB-007 | SSH hardening â€” ciphers, MACs, auth settings â€” Debian 12 | — | ✓ 5.2.3, 5.2.4, 5.2.5, 5.2.6, 5.2.7, 5.2.8 | — | ✓ 2.2.7, 8.2.6 | ✓ CC6.1, CC6.7 | ✓ AC-17, IA-2, SC-8 |
| DEB-008 | PAM faillock â€” account lockout after 5 failed attempts â€” Debian 12 | — | ✓ 5.3.2 | — | ✓ 8.3.4 | ✓ CC6.1 | ✓ AC-7 |
| DEB-009 | Remove unnecessary network services â€” Debian 12 | — | ✓ 2.1.1, 2.2.1, 2.3.1 | — | ✓ 2.2.1, 1.3.1 | — | ✓ CM-7 |
| DEB-010 | Configure auditd with PCI-DSS audit rules â€” Debian 12 | — | ✓ 4.1.1, 4.1.2, 4.1.3 | — | ✓ 10.2.1.1, 10.2.1.2, 10.5.1, 10.7.1 | ✓ CC7.1, CC7.2 | ✓ AU-2, AU-4, AU-12 |
| DEB-011 | System file permissions and local user hygiene â€” Debian 12 | — | ✓ 6.1.1, 6.1.2, 6.1.3, 6.1.4, 6.2.1, 6.2.5 | — | ✓ 2.2.1 | ✓ CC6.1 | ✓ AC-3, IA-5 |
| FIM-001 | AIDE file integrity monitoring | ✓ 1.3.1, 1.3.2, 1.3.3 | — | — | ✓ 11.3.1, 11.3.2 | ✓ CC6.8, CC7.2 | ✓ SI-7 |
| FIPS-001 | Enable FIPS 140-2/3 mode (kernel crypto + OpenSSL FIPS provider) | — | — | — | ✓ 4.2.1, 6.3.1 | ✓ CC6.1, CC6.7 | ✓ SC-12, SC-13, IA-7 |
| FIPS-002 | Set OS crypto policy to FIPS via update-crypto-policies | — | — | — | ✓ 4.2.1 | — | ✓ SC-12, SC-13 |
| FS-001 | Disable unused filesystems (cramfs, squashfs, udf, usb-storage) | ✓ 1.1.1.1, 1.1.1.2, 1.1.1.3, 1.1.1.4 | — | — | ✓ 2.2.1 | — | ✓ CM-7 |
| FS-002 | Secure /tmp mount with noexec,nosuid,nodev | ✓ 1.1.2.2, 1.1.2.3, 1.1.2.4 | — | — | ✓ 2.2.1 | — | — |
| FS-003 | Enable ASLR | ✓ 1.5.2 | — | — | — | — | ✓ SI-16 |
| FS-004 | Enable SELinux in enforcing mode (targeted policy) | ✓ 1.6.1.2, 1.6.1.3 | — | — | ✓ 2.2.1, 6.3.1 | ✓ CC6.1, CC6.8 | ✓ AC-3, AC-6 |
| K8S-001 | Disable kubelet anonymous authentication | — | — | ✓ 4.2.1 | ✓ 7.2.1 | — | ✓ AC-3, IA-2 |
| K8S-002 | Disable kubelet read-only port | — | — | ✓ 4.2.4 | ✓ 1.3.1 | — | ✓ CM-7 |
| K8S-003 | Enable kubelet protect-kernel-defaults | — | — | ✓ 4.2.6 | — | — | ✓ CM-6 |
| K8S-004 | Set kubelet TLS minimum version and cipher suites | — | — | ✓ 4.2.12 | ✓ 4.2.1 | ✓ CC6.7 | ✓ SC-8, SC-28 |
| K8S-005 | Deploy hardened containerd config (SystemdCgroup, seccomp) | — | — | ✓ 5.1.3, 5.2.1 | ✓ 2.2.1, 6.3.1 | — | ✓ CM-6, CM-7 |
| K8S-006 | Ensure kubelet service file permissions are 600 | — | — | ✓ 4.1.1 | ✓ 2.2.1 | — | ✓ AC-3 |
| K8S-007 | Set kubelet authorization mode to Webhook | — | — | ✓ 4.2.2 | ✓ 7.2.1 | — | ✓ AC-3, IA-2 |
| K8S-008 | Enable kubelet certificate rotation | — | — | ✓ 4.2.11 | ✓ 4.2.1, 6.3.1 | ✓ CC6.7 | ✓ SC-12, IA-5 |
| K8S-009 | Set kubelet event-qps to limit API server event flooding | — | — | ✓ 4.2.9 | — | — | ✓ AU-5, SC-5 |
| K8S-010 | Set kubelet streaming-connection-idle-timeout | — | — | ✓ 4.2.5 | ✓ 8.2.8 | — | ✓ AC-11, CM-6 |
| KERN-001 | Restrict kernel dmesg (dmesg_restrict=1) | — | — | — | ✓ 2.2.5 | — | ✓ CM-6, SI-3 |
| KERN-002 | Restrict kernel pointer exposure (kptr_restrict=2) | — | — | — | ✓ 2.2.5 | — | ✓ CM-6, SI-3 |
| KERN-003 | Disable Bluetooth kernel module | — | — | — | ✓ 2.2.4, 1.3.1 | — | ✓ CM-7 |
| LOG-001 | Configure auditd with retention and disk-full actions | ✓ 4.1.2.1, 4.1.2.2, 4.1.2.3, 4.1.2.4, 4.1.2.5, 4.1.2.6, 4.1.2.7 | — | — | ✓ 10.5.1, 10.7.1 | ✓ CC7.1, CC7.2 | ✓ AU-4, AU-5 |
| LOG-002 | Deploy CIS baseline audit rules (identity, sudo, privileged commands, mounts) | ✓ 4.1.3.1, 4.1.3.2, 4.1.3.4, 4.1.3.5, 4.1.3.7, 4.1.3.9, 4.1.3.10, 4.1.3.11, 4.1.3.12 | — | — | ✓ 10.2.1.1, 10.2.1.2, 10.2.1.5, 10.2.1.7 | ✓ CC7.2, CC7.3 | ✓ AU-2, AU-12 |
| LOG-003 | Deploy PCI-DSS-specific audit rules (cardholder data, authentication mechanisms) | — | — | — | ✓ 10.2.1.1, 10.2.1.2, 10.2.1.3, 10.2.1.4, 10.2.1.5, 10.2.1.6, 10.2.1.7, 10.2.2, 10.3.2 | ✓ CC7.2 | ✓ AU-2, AU-12, SI-4 |
| LOG-004 | Configure rsyslog for local log persistence and retention | ✓ 4.2.1.1, 4.2.1.2, 4.2.1.3 | — | — | ✓ 10.3.1, 10.5.1, 10.7.1 | ✓ CC7.1, CC7.2 | ✓ AU-3, AU-9, AU-11 |
| LOG-005 | Configure systemd-journald for persistent storage and rate limiting | ✓ 4.2.2.1, 4.2.2.2 | — | — | ✓ 10.5.1, 10.7.1 | — | ✓ AU-4, AU-9 |
| MAINT-001 | Ensure permissions on /etc/passwd are 644 root:root | ✓ 6.1.1 | — | — | ✓ 2.2.1 | ✓ CC6.1 | ✓ AC-3, IA-5 |
| MAINT-002 | Ensure permissions on /etc/shadow are 0000 root:root | ✓ 6.1.2 | — | — | ✓ 2.2.1, 8.2.1 | ✓ CC6.1 | ✓ AC-3, IA-5 |
| MAINT-003 | Ensure permissions on /etc/group and /etc/gshadow are correct | ✓ 6.1.3, 6.1.4 | — | — | ✓ 2.2.1 | — | ✓ AC-3 |
| MAINT-004 | Ensure no world-writable files exist | ✓ 6.1.8 | — | — | ✓ 2.2.1, 6.3.1 | ✓ CC6.1 | ✓ AC-3, CM-6 |
| MAINT-005 | Ensure no unexpected SUID/SGID executables exist | ✓ 6.1.10, 6.1.11 | — | — | ✓ 2.2.5, 6.3.1 | ✓ CC6.8 | ✓ AC-6, CM-6 |
| MAINT-006 | Ensure sticky bit is set on world-writable directories | ✓ 6.1.12 | — | — | ✓ 2.2.1 | — | ✓ CM-6 |
| MAINT-007 | Ensure no accounts have empty password fields | ✓ 6.2.1 | — | — | ✓ 8.2.1, 8.3.1 | ✓ CC6.1 | ✓ IA-5 |
| MAINT-008 | Ensure root is the only UID 0 account | ✓ 6.2.5 | — | — | ✓ 8.2.1, 7.2.1 | ✓ CC6.2 | ✓ IA-2, AC-6 |
| NET-001 | Disable uncommon network protocols (DCCP, SCTP, RDS, TIPC) | ✓ 3.4.1, 3.4.2, 3.4.3, 3.4.4 | — | — | ✓ 1.3.1 | — | ✓ CM-7 |
| NET-002 | Harden IPv4 kernel network parameters | ✓ 3.2.1, 3.2.2, 3.2.3, 3.2.4, 3.2.5, 3.2.6, 3.3.1, 3.3.2, 3.3.3 | — | — | ✓ 1.3.2 | — | ✓ SC-5, SC-7 |
| NET-003 | Disable IPv6 on node interfaces not requiring it | ✓ 3.1.1, 3.1.2 | — | — | ✓ 1.3.1, 1.3.2 | — | ✓ CM-7, SC-7 |
| RHEL-001 | Disable unused filesystems (cramfs, squashfs, udf, usb-storage) â€” RHEL 9 | — | — | — | ✓ 2.2.1 | — | ✓ CM-7 |
| RHEL-002 | Secure /tmp as tmpfs with noexec,nosuid,nodev â€” RHEL 9 | — | — | — | ✓ 2.2.1 | — | ✓ CM-7 |
| RHEL-003 | Enable ASLR (kernel.randomize_va_space=2) â€” RHEL 9 | — | — | — | ✓ 2.2.5 | — | ✓ SI-16 |
| RHEL-004 | Enable SELinux in enforcing mode â€” RHEL 9 | — | — | — | ✓ 2.2.1, 6.3.1 | ✓ CC6.1, CC6.8 | ✓ AC-3, AC-6 |
| RHEL-005 | Remove unnecessary network services â€” RHEL 9 | — | — | — | ✓ 2.2.1, 1.3.1 | — | ✓ CM-7 |
| RHEL-006 | Disable uncommon network protocols and harden sysctl network params â€” RHEL 9 | — | — | — | ✓ 1.2.5, 1.3.2 | — | ✓ CM-7, SC-5, SC-7 |
| RHEL-007 | Configure auditd with PCI-DSS audit rules â€” RHEL 9 | — | — | — | ✓ 10.2.1.1, 10.2.1.2, 10.5.1, 10.7.1 | ✓ CC7.1, CC7.2 | ✓ AU-2, AU-4, AU-12 |
| RHEL-008 | SSH hardening â€” ciphers, MACs, auth settings â€” RHEL 9 | — | — | — | ✓ 2.2.7, 8.2.6, 8.3.4 | ✓ CC6.1, CC6.7 | ✓ AC-17, IA-2, SC-8 |
| RHEL-009 | PAM faillock and password quality â€” RHEL 9 | — | — | — | ✓ 8.3.4, 8.3.6 | ✓ CC6.1 | ✓ AC-7, IA-5 |
| RHEL-010 | System file permissions and local user hygiene â€” RHEL 9 | — | — | — | ✓ 2.2.1 | ✓ CC6.1 | ✓ AC-3, IA-5 |
| SOC2-001 | Protect /etc/shadow (mode 0000) | — | — | — | ✓ 8.2.1 | ✓ CC6.1 | ✓ AC-3, IA-5 |
| SOC2-002 | Enable login history via pam_lastlog | — | — | — | ✓ 10.2.1.5 | ✓ CC6.2 | ✓ AC-9, AU-14 |
| SOC2-003 | Block ICMP redirects (accept_redirects=0) | — | — | — | ✓ 1.3.2 | ✓ CC6.6 | ✓ SC-5, SC-7 |
| SOC2-004 | Deploy SOC2 CC7 audit rules (kubectl, shell exec, interpreter exec) | — | — | — | ✓ 10.2.1.1, 10.2.1.7 | ✓ CC7.2 | ✓ AU-2, AU-12, SI-4 |
| SOC2-005 | Configure rsyslog authpriv logging to /var/log/secure | — | — | — | ✓ 10.3.1, 10.5.1 | ✓ CC7.2 | ✓ AU-3, AU-9 |
| SSM-001 | Disable SSH â€” enforce SSM Session Manager for node access | — | — | — | ✓ 8.2.1, 8.2.3 | ✓ CC6.1, CC6.2 | ✓ AC-17, CM-7 |
| SSM-002 | Block TCP port 22 via iptables â€” no SSH ingress possible | — | — | — | ✓ 1.3.1, 8.2.1 | ✓ CC6.6 | ✓ CM-7, SC-7 |
| SVC-001 | Remove unnecessary network services | ✓ 2.2.1-2.2.21 | — | — | ✓ 1.3.1, 2.2.1 | ✓ CC6.6 | ✓ CM-7 |
| TIME-001 | Configure chronyd with Amazon Time Sync Service | ✓ 2.1.x | — | — | ✓ 10.6.1, 10.6.2, 10.6.3 | ✓ CC7.1 | ✓ AU-8 |

## Controls by Role

- **`aide`**: FIM-001
- **`auditd-pci`**: LOG-003
- **`chrony-hardened`**: TIME-001
- **`cis-debian12`**: DEB-001, DEB-002, DEB-003, DEB-004, DEB-005, DEB-006, DEB-007, DEB-008, DEB-009, DEB-010, DEB-011
- **`cis-k8s-worker`**: K8S-001, K8S-002, K8S-003, K8S-004, K8S-005, K8S-006, K8S-007, K8S-008, K8S-009, K8S-010
- **`cis-l2`**: ACC-001, ACC-002, ACC-003, FS-001, FS-002, FS-003, FS-004, LOG-001, LOG-002, LOG-004, LOG-005, MAINT-001, MAINT-002, MAINT-003, MAINT-004, MAINT-005, MAINT-006, MAINT-007, MAINT-008, NET-001, NET-002, NET-003, SVC-001
- **`cis-rhel9`**: RHEL-001, RHEL-002, RHEL-003, RHEL-004, RHEL-005, RHEL-006, RHEL-007, RHEL-008, RHEL-009, RHEL-010
- **`fips-mode`**: CM-002, FIPS-001, FIPS-002
- **`pci-dss-v4`**: ACC-004, ACC-005, ACC-006, KERN-001, KERN-002, KERN-003
- **`soc2-cc6-cc7-cc8`**: CM-001, SOC2-001, SOC2-002, SOC2-003, SOC2-004, SOC2-005
- **`ssm-only-access`**: SSM-001, SSM-002

## Framework Requirement Counts

- **CIS Amazon Linux 2023 Benchmark Level 2**: 25 controls covering 66 requirement IDs
- **CIS_Debian12_L2**: 11 controls covering 34 requirement IDs
- **CIS Kubernetes Benchmark v1.8**: 10 controls covering 11 requirement IDs
- **PCI-DSS v4.0**: 71 controls covering 40 requirement IDs
- **SOC 2 Trust Service Criteria**: 41 controls covering 10 requirement IDs
- **NIST SP 800-53 Rev 5**: 72 controls covering 33 requirement IDs