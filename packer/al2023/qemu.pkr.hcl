# TabyaOS — QEMU/QCOW2 builder
# Produces a locally-bootable hardened image for KVM/bare-metal targets.
# Source: official AL2023 KVM cloud image (QCOW2).
# Output: output/al2023-qcow2/tabyaos-al2023-x86_64-<timestamp>.qcow2
#
# Prerequisites (Linux host):
#   sudo apt install qemu-system-x86 qemu-utils  # Debian/Ubuntu
#   sudo dnf install qemu-kvm qemu-img           # RHEL/AL2023
#
# Prerequisites (macOS host, Intel only):
#   brew install qemu
#   # Set qemu_accelerator=hvf in vars.

# ─────────────────────────────────────────────────────────────────────────────
# Locals
# ─────────────────────────────────────────────────────────────────────────────

locals {
  qemu_ami_tags = merge(
    {
      Project        = "tabyaos"
      EKSVersion     = var.eks_version
      HardeningLevel = "baseline"
      ManagedBy      = "packer-qemu"
      BuildTimestamp = timestamp()
      OutputFormat   = "qcow2"
    },
    var.tags
  )

  qemu_vm_name = "${var.ami_name_prefix}-x86_64-eks${var.eks_version}-{{timestamp}}.qcow2"
}

# ─────────────────────────────────────────────────────────────────────────────
# Source
# ─────────────────────────────────────────────────────────────────────────────

source "qemu" "al2023-qcow2" {
  # ── Source image ────────────────────────────────────────────────────────────
  iso_url      = var.al2023_qcow2_url
  iso_checksum = var.al2023_qcow2_checksum
  disk_image   = true     # Source is an existing disk image, not an installer ISO.

  # ── Output ──────────────────────────────────────────────────────────────────
  output_directory = var.qemu_output_dir
  vm_name          = local.qemu_vm_name
  format           = "qcow2"
  disk_compression = true

  # ── VM hardware ─────────────────────────────────────────────────────────────
  headless         = true
  net_device       = "virtio-net"
  disk_interface   = "virtio"
  machine_type     = "q35"
  accelerator      = var.qemu_accelerator

  qemuargs = [
    ["-m", "${var.qemu_memory_mb}"],
    ["-smp", "${var.qemu_cpus}"],
    # Serial console — required for headless AL2023 kernel output.
    ["-serial", "file:/tmp/tabyaos-qemu-serial.log"],
    # VirtIO random number device — improves entropy, speeds cloud-init.
    ["-device", "virtio-rng-pci"],
  ]

  # ── Cloud-init NoCloud seed ──────────────────────────────────────────────────
  # Packer creates a CD-ROM ISO from these two files.
  # Label "cidata" is the cloud-init NoCloud magic string.
  cd_files = [
    "${path.root}/cloud-init/user-data",
    "${path.root}/cloud-init/meta-data",
  ]
  cd_label = "cidata"

  # ── SSH communicator ─────────────────────────────────────────────────────────
  communicator     = "ssh"
  ssh_username     = "ec2-user"
  ssh_password     = var.qemu_ssh_password
  ssh_timeout      = "15m"

  # Wait for cloud-init to finish before attempting SSH.
  # AL2023 cloud images typically boot in ~30s with KVM.
  boot_wait        = "30s"

  shutdown_command = "sudo systemctl poweroff"
}

# ─────────────────────────────────────────────────────────────────────────────
# Build
# ─────────────────────────────────────────────────────────────────────────────

build {
  name    = "tabyaos-al2023-qcow2"
  sources = ["source.qemu.al2023-qcow2"]

  # Wait for cloud-init to signal completion before provisioning.
  provisioner "shell" {
    inline = [
      "timeout 120 bash -c 'until [ -f /tmp/cloud-init-done ]; do sleep 2; done'",
      "cloud-init status --wait || true",
    ]
    pause_before = "5s"
  }

  # Apply pending security updates.
  provisioner "shell" {
    inline = [
      "sudo dnf update -y --security",
      "sudo dnf clean all",
    ]
  }

  # Verify EKS bootstrap artefacts (same check as amazon-ebs build).
  provisioner "shell" {
    inline = [
      "echo '=== EKS bootstrap check ==='",
      "test -f /etc/eks/bootstrap.sh || echo 'INFO: /etc/eks/bootstrap.sh not present (expected for KVM/bare-metal target)'",
      "kubelet --version 2>/dev/null || echo 'INFO: kubelet not pre-installed (inject via bootstrap)'",
      "containerd --version 2>/dev/null || echo 'INFO: containerd not pre-installed'",
      "echo '=== Baseline OK ==='",
    ]
  }

  # Write build provenance.
  provisioner "shell" {
    inline = [
      "echo \"TabyaOS AL2023 QCOW2 baseline — built $(date -u +%Y-%m-%dT%H:%M:%SZ)\" | sudo tee /etc/tabyaos-release",
      "echo \"EKSVersion=${var.eks_version}\" | sudo tee -a /etc/tabyaos-release",
      "echo \"HardeningLevel=baseline\" | sudo tee -a /etc/tabyaos-release",
      "echo \"OutputFormat=qcow2\" | sudo tee -a /etc/tabyaos-release",
    ]
  }

  # Seal: remove the ephemeral build password and lock the account.
  # SSH (or SSM) will be the only access method after hardening is applied.
  provisioner "shell" {
    inline = [
      "sudo passwd -l ec2-user",
      "sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config || true",
      "sudo cloud-init clean --logs",
    ]
  }
}
