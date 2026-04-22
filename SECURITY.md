# Security Policy

## Supported Versions

| Version | Support Status |
|---------|---------------|
| `main` branch | Active development — security fixes applied immediately |
| Latest release tag | Security patches backported |
| Older releases | Community support only |

Enterprise LTS customers receive 18-month backport guarantees on each LTS release.

## Reporting a Vulnerability

**Do not open a public GitHub issue for security vulnerabilities.**

Report vulnerabilities via one of these channels:

1. **GitHub Private Vulnerability Reporting** (preferred):
   - Navigate to the [Security tab](../../security/advisories/new) of this repository
   - Click "Report a vulnerability"

2. **Email**: security@tabya.io
   - Encrypt with our PGP key (key ID: published at tabya.io/.well-known/security.txt)

Please include:

- Description of the vulnerability
- Steps to reproduce
- Affected versions
- Potential impact
- Any suggested remediation (optional)

## Response Timeline

| Event | Target |
|-------|--------|
| Acknowledgement | 48 hours |
| Initial assessment | 5 business days |
| Fix for Critical/High CVE | 7 days |
| Fix for Medium CVE | 30 days |
| Fix for Low CVE | 90 days |
| Public disclosure | After fix is released or 90 days, whichever comes first |

Enterprise SLA customers receive direct Slack/Teams notification within 24 hours of any Critical CVE affecting their deployed version.

## Scope

In scope:
- Ansible roles and tasks in `ansible/roles/`
- Packer build configurations in `packer/`
- CI/CD pipeline security in `.github/workflows/`
- Supply chain: dependency pinning, Cosign signatures, SBOM accuracy

Out of scope:
- Vulnerabilities in third-party packages (upstream Amazon Linux, kernel, openssl) — report to the respective project
- Application-level vulnerabilities in workloads running on TabyaOS nodes

## Security Design Principles

1. **No long-lived credentials** — all cloud auth uses GitHub Actions OIDC
2. **Signed artefacts** — every release is Cosign-signed with keyless OIDC
3. **SBOM-published** — CycloneDX SBOM attached to every release
4. **Dependency pinning** — Ansible, Packer, and tool versions pinned in CI
5. **Minimal surface** — no SSH, no package manager in production images
