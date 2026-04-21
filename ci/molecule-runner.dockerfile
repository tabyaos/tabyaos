# TabyaOS Molecule runner image.
# Used on Windows (and optionally in CI) to run Ansible molecule tests
# without requiring a native POSIX Python environment.
#
# Build:   docker build -f ci/molecule-runner.dockerfile -t tabyaos/molecule-runner ci/
# Run:     see Justfile target `test-molecule`
#
# The container mounts:
#   - The repo root       → /project   (read the role code)
#   - Docker socket       → lets molecule spin up docker://amazonlinux:2023 containers
#                           using the HOST Docker daemon (Docker-outside-of-Docker).

FROM python:3.12-slim

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      git \
      rsync \
      openssh-client \
    && rm -rf /var/lib/apt/lists/*

# Pin versions for reproducibility; bump intentionally.
RUN pip install --no-cache-dir \
    "molecule==6.*" \
    "molecule-plugins[docker]" \
    "ansible-core==2.17.*" \
    "ansible-lint==24.*" \
    "docker>=7"

WORKDIR /project

# Default: run all scenarios in the ansible/roles subtree.
ENTRYPOINT ["bash", "-c"]
CMD ["find ansible/roles -name molecule.yml -exec dirname {} \\; | xargs -P4 -I{} bash -c 'cd {}/../.. && echo \"=== $(basename $(pwd)) ===\" && molecule test'"]
