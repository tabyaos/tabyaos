#!/usr/bin/env python3
"""
TabyaOS local AI helper — routes tasks to local Ollama models.

Usage:
  python3 scripts/local-ai.py <task> [options]

Tasks:
  gen-role       <role-name> <description>     Generate a new Ansible role scaffold
  gen-verify     <role-name>                   Generate verify.yml from role tasks
  gen-tasks      <prompt>                      Generate Ansible tasks for a requirement
  expand-control <control-id> <description>    Expand a compliance control definition
  review-yaml    <file>                        Lint and suggest improvements for a YAML file
  ask            <model> <prompt>              Raw query to a specific model

Models (aliases):
  coder    = qwen2.5-coder:32b   (default for code tasks)
  devops   = devstral-small-2:24b
  deep     = deepseek-coder:33b
  big      = gpt-oss:120b        (use sparingly — 65 GB)
"""

import argparse
import json
import sys
from pathlib import Path
import urllib.request
import urllib.error

OLLAMA_URL = "http://localhost:11434/api/generate"

MODELS = {
    "coder":  "qwen2.5-coder:32b",
    "devops": "devstral-small-2:24b",
    "deep":   "deepseek-coder:33b",
    "big":    "gpt-oss:120b",
    "fast":   "mistral:7b",
    "qwen3": "qwen3-coder:30b",
}

PROJECT_CONTEXT = """
You are working on TabyaOS — a hardened Amazon Linux 2023 OS image for Kubernetes worker nodes.
The project uses:
- Ansible roles for OS hardening (CIS L2, PCI-DSS v4.0, SOC 2 Type II, CIS K8s v1.8)
- Molecule for role testing (Docker driver, amazonlinux:2023 container)
- Packer HCL2 for AMI building
- Every control references a framework ID in a comment (e.g. # CIS AL2023 5.2.3)
- manage_services variable guards all service tasks (false in Docker containers)
- force: false on ansible.builtin.copy for idempotent file creation

Coding conventions:
- YAML: 2-space indent, double-quoted strings for Ansible task names
- All hardening is idempotent
- Molecule verify.yml uses ansible.builtin.slurp + b64decode for content checks
- No comments explaining WHAT code does — only WHY (hidden constraints, workarounds)
"""


def resolve_model(alias: str) -> str:
    return MODELS.get(alias, alias)


def ollama_generate(model: str, prompt: str, stream: bool = True) -> str:
    model = resolve_model(model)
    payload = json.dumps({
        "model": model,
        "prompt": prompt,
        "stream": stream,
    }).encode()

    req = urllib.request.Request(
        OLLAMA_URL,
        data=payload,
        headers={"Content-Type": "application/json"},
    )

    result = []
    try:
        with urllib.request.urlopen(req, timeout=300) as resp:
            for line in resp:
                chunk = json.loads(line.decode())
                token = chunk.get("response", "")
                result.append(token)
                print(token, end="", flush=True)
                if chunk.get("done"):
                    break
    except urllib.error.URLError as e:
        print(f"\nERROR: Cannot reach Ollama at {OLLAMA_URL}: {e}", file=sys.stderr)
        sys.exit(1)

    print()  # newline after stream
    return "".join(result)


def task_gen_role(role_name: str, description: str) -> None:
    prompt = f"""{PROJECT_CONTEXT}

Generate a complete Ansible role scaffold for role name: {role_name}
Description: {description}

Output the following files with full content:
1. tasks/main.yml — all hardening tasks with framework ID comments
2. defaults/main.yml — all configurable variables with sane defaults
3. molecule/default/molecule.yml — molecule config using Docker driver, amazonlinux:2023
4. molecule/default/converge.yml — with manage_services: false var
5. molecule/default/verify.yml — content-level assertions (slurp + b64decode pattern)

Use --- YAML document separator before each file and a comment # FILE: <path> to label it.
"""
    print(f"[local-ai] gen-role '{role_name}' using qwen2.5-coder:32b\n", file=sys.stderr)
    ollama_generate("coder", prompt)


def task_gen_verify(role_name: str) -> None:
    role_path = Path(f"ansible/roles/{role_name}/tasks/main.yml")
    if not role_path.exists():
        print(f"ERROR: {role_path} not found", file=sys.stderr)
        sys.exit(1)

    tasks_content = role_path.read_text()
    prompt = f"""{PROJECT_CONTEXT}

Given these Ansible tasks for role '{role_name}':

{tasks_content}

Write a Molecule verify.yml that:
1. Checks EVERY file the tasks create (stat + assert exists + correct mode/uid)
2. For config files: slurp + b64decode + assert actual hardened values are present
3. For sysctl files: assert both 'key=value' and 'key = value' formats (ansible.posix.sysctl writes with spaces)
4. For shell grep checks: use changed_when: false
5. Labels each assertion with the framework requirement (fail_msg includes e.g. "CIS 3.2.2:")

Output only the YAML content for verify.yml, starting with ---.
"""
    print(f"[local-ai] gen-verify '{role_name}' using qwen2.5-coder:32b\n", file=sys.stderr)
    ollama_generate("coder", prompt)


def task_gen_tasks(requirement_prompt: str) -> None:
    prompt = f"""{PROJECT_CONTEXT}

Write Ansible tasks to implement the following hardening requirement:
{requirement_prompt}

Requirements:
- Every task has a name starting with the framework requirement ID
- Use ansible.builtin.* FQCN for all modules
- Guard service tasks with: when: manage_services | default(true)
- Use ansible.builtin.copy with force: false for idempotent file creation
- Output only YAML task blocks, no extra explanation.
"""
    print(f"[local-ai] gen-tasks using qwen2.5-coder:32b\n", file=sys.stderr)
    ollama_generate("coder", prompt)


def task_expand_control(control_id: str, description: str) -> None:
    mappings_path = Path("compliance/control-mappings.yaml")
    if mappings_path.exists():
        existing = mappings_path.read_text()[:3000]
    else:
        existing = ""

    prompt = f"""{PROJECT_CONTEXT}

Existing control-mappings.yaml excerpt:
{existing}

Generate a new control entry for:
  id: {control_id}
  description: {description}

Follow the exact YAML structure of the existing controls — include:
  id, title, description, ansible_role, ansible_task_pattern, frameworks (with requirement IDs), severity, testable

Output only the YAML block for the new control (starting with - id:).
"""
    print(f"[local-ai] expand-control '{control_id}' using devstral-small-2:24b\n", file=sys.stderr)
    ollama_generate("devops", prompt)


def task_review_yaml(file_path: str) -> None:
    content = Path(file_path).read_text()
    prompt = f"""{PROJECT_CONTEXT}

Review this Ansible YAML file for:
1. Idempotency issues (tasks that will always report 'changed')
2. Missing changed_when: false on shell/command tasks
3. Missing force: false on copy tasks used for idempotent file creation
4. Service tasks not guarded by manage_services variable
5. Non-FQCN module names (should use ansible.builtin.*)
6. Any other quality issues

File: {file_path}
Content:
{content}

For each issue found, show the line and the fix. If no issues, say "LGTM".
"""
    print(f"[local-ai] review-yaml '{file_path}' using qwen2.5-coder:32b\n", file=sys.stderr)
    ollama_generate("coder", prompt)


def task_ask(model: str, prompt_text: str) -> None:
    full_prompt = f"{PROJECT_CONTEXT}\n\n{prompt_text}"
    print(f"[local-ai] ask → {resolve_model(model)}\n", file=sys.stderr)
    ollama_generate(model, full_prompt)


def main():
    parser = argparse.ArgumentParser(description="TabyaOS local AI task runner")
    sub = parser.add_subparsers(dest="task", required=True)

    p = sub.add_parser("gen-role", help="Generate a new role scaffold")
    p.add_argument("role_name")
    p.add_argument("description")

    p = sub.add_parser("gen-verify", help="Generate verify.yml from role tasks")
    p.add_argument("role_name")

    p = sub.add_parser("gen-tasks", help="Generate Ansible tasks for a requirement")
    p.add_argument("requirement", nargs="+")

    p = sub.add_parser("expand-control", help="Generate a compliance control entry")
    p.add_argument("control_id")
    p.add_argument("description", nargs="+")

    p = sub.add_parser("review-yaml", help="Review a YAML file for quality issues")
    p.add_argument("file")

    p = sub.add_parser("ask", help="Raw query to a model")
    p.add_argument("model", choices=list(MODELS.keys()) + list(MODELS.values()))
    p.add_argument("prompt", nargs="+")

    args = parser.parse_args()

    if args.task == "gen-role":
        task_gen_role(args.role_name, args.description)
    elif args.task == "gen-verify":
        task_gen_verify(args.role_name)
    elif args.task == "gen-tasks":
        task_gen_tasks(" ".join(args.requirement))
    elif args.task == "expand-control":
        task_expand_control(args.control_id, " ".join(args.description))
    elif args.task == "review-yaml":
        task_review_yaml(args.file)
    elif args.task == "ask":
        task_ask(args.model, " ".join(args.prompt))


if __name__ == "__main__":
    main()
