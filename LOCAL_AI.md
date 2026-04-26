# Local AI Workflow

Token-free code generation via local Ollama models for repetitive/boilerplate tasks.

## Model assignments

| Model | Alias | Best for |
|-------|-------|----------|
| `qwen2.5-coder:32b` | `coder` | Ansible tasks, Molecule tests, YAML generation |
| `devstral-small-2:24b` | `devops` | CI/CD scripts, compliance control entries |
| `deepseek-coder:33b` | `deep` | Complex role logic, alternate code review pass |
| `qwen3-coder:30b` | add to MODELS | Next-gen coder, use when downloaded |
| `mistral:7b` | `fast` | Quick one-liners, sanity checks |
| `gpt-oss:120b` | `big` | Last resort for very hard problems |

## What to run locally vs. Claude

| Task | Use |
|------|-----|
| New role boilerplate (`tasks/`, `defaults/`, `molecule/`) | `just ai-gen-role` |
| Generate verify.yml from existing tasks | `just ai-gen-verify` |
| New Ansible tasks for a known requirement | `just ai-gen-tasks` |
| New compliance control entry | `just ai-expand-control` |
| YAML idempotency/quality review | `just ai-review` |
| Debugging a failing Molecule test | **Claude** |
| Architectural decisions (new framework, new OS) | **Claude** |
| Security-sensitive code (crypto, auth) | **Claude** |
| Fixing a subtle Ansible idempotency bug | **Claude** |

## Quick examples

```bash
# Scaffold a new role for RHEL 9 CIS baseline
just ai-gen-role rhel9-cis-l2 "CIS Red Hat Enterprise Linux 9 Benchmark Level 2"

# Regenerate verify.yml after changing aide/tasks/main.yml
just ai-gen-verify aide

# Generate tasks for a specific PCI requirement
just ai-gen-tasks "PCI-DSS Req 10.3.3: protect audit log files from destruction and unauthorized modifications"

# Add a new control to control-mappings.yaml
just ai-expand-control NET-002 "Disable IPv6 on non-required interfaces per CIS AL2023 3.1.2"

# Review a role for idempotency issues before committing
just ai-review ansible/roles/soc2-cc6-cc7-cc8/tasks/main.yml

# Quick question
just ai-ask coder "what is the correct auditd rule syntax to watch /etc/passwd for writes?"
```

## Adding qwen3-coder once downloaded

Edit `scripts/local-ai.py`, find the `MODELS` dict and add:
```python
"qwen3": "qwen3-coder:30b",
```
