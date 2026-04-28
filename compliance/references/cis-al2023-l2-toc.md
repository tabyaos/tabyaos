# CIS Amazon Linux 2023 Benchmark Level 2 — Table of Contents

> **ACTION REQUIRED (Maintainer):** This file is a stub. Populate it with the CIS AL2023 L2 benchmark TOC
> (available from CIS at cisecurity.org after free registration). The TOC is used by Phase 2 gap analysis
> to identify which CIS controls are implemented in Ansible but not yet mapped in control-mappings.yaml.
>
> Format each section as:
> ```
> ## Section 1 — Initial Setup
> - 1.1.1.1 Ensure mounting of cramfs filesystems is disabled
> - 1.1.1.2 Ensure mounting of squashfs filesystems is disabled
> ...
> ```

## Known gaps (from Phase 2 overnight audit, 2026-04-28)

The following CIS AL2023 sections are implemented in `ansible/roles/cis-l2/` but were not yet
mapped in `compliance/control-mappings.yaml` before the overnight batch:

- **Section 6.1** — System file permissions (`tasks/6_maintenance.yml`)
  - 6.1.1 /etc/passwd permissions
  - 6.1.2 /etc/shadow permissions
  - 6.1.3 /etc/group permissions
  - 6.1.4 /etc/gshadow permissions
  - 6.1.8 No world-writable files
  - 6.1.10/6.1.11 No unexpected SUID/SGID executables
  - 6.1.12 Sticky bit on world-writable directories
- **Section 6.2** — Local user and group settings (`tasks/6_maintenance.yml`)
  - 6.2.1 No empty password fields
  - 6.2.5 Root is only UID 0 account

These controls were added to `compliance/control-mappings.yaml` in the overnight batch as MAINT-001 through MAINT-008.
