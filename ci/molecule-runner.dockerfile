# TabyaOS Molecule runner image.
# Used on Windows (and optionally in CI) to run Ansible molecule tests
# without requiring a native POSIX Python environment.
#
# Build:   docker build -f ci/molecule-runner.dockerfile -t tabyaos/molecule-runner ci/
# Run:     see Justfile target `test-molecule`
#
# The container mounts:
#   - The repo root  → /project  (read the role code)
#   - Docker socket  → lets molecule spin up amazonlinux:2023 containers
#                      using the HOST Docker daemon (Docker-outside-of-Docker).
#
# Requires Docker CLI in PATH so Ansible's docker connection plugin can
# exec into test containers via the mounted host socket.

FROM python:3.12-slim

# Install Docker CLI (not the daemon) + basic tools.
RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      ca-certificates curl gnupg lsb-release \
    && install -m 0755 -d /etc/apt/keyrings \
    && curl -fsSL https://download.docker.com/linux/debian/gpg \
       | gpg --dearmor -o /etc/apt/keyrings/docker.gpg \
    && chmod a+r /etc/apt/keyrings/docker.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) \
       signed-by=/etc/apt/keyrings/docker.gpg] \
       https://download.docker.com/linux/debian \
       $(lsb_release -cs) stable" \
       > /etc/apt/sources.list.d/docker.list \
    && apt-get update -qq \
    && apt-get install -y --no-install-recommends \
         docker-ce-cli \
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

# ansible.posix for sysctl, community.general for extras, community.docker for
# the molecule docker connection plugin used during verify playbooks.
RUN ansible-galaxy collection install ansible.posix community.general community.docker

WORKDIR /project

ENV ANSIBLE_STDOUT_CALLBACK=default

# Default: run all scenarios in the ansible/roles subtree.
ENTRYPOINT ["bash", "-c"]
CMD ["find ansible/roles -name molecule.yml -exec dirname {} \\; | xargs -P4 -I{} bash -c 'cd {}/../.. && echo \"=== $(basename $(pwd)) ===\" && molecule test'"]
