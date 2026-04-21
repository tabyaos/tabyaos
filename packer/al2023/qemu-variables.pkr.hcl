
# ─── QEMU/QCOW2-specific variables ──────────────────────────────────────────
# These are separate from the amazon-ebs variables to keep the local build
# path self-contained. All names are prefixed qemu_ to avoid clashes.

variable "al2023_qcow2_url" {
  type        = string
  # Amazon Linux 2023 KVM cloud image.
  # Find the latest at: https://cdn.amazonlinux.com/al2023/os-images/latest/kvm/
  # Update the URL AND checksum together.
  default     = "https://cdn.amazonlinux.com/al2023/os-images/2023.6.20250303.0/kvm/al2023-kvm-2023.6.20250303.0-kernel-6.1-x86_64.xfs.gpt.qcow2"
  description = "URL to the AL2023 KVM QCOW2 base image."
}

variable "al2023_qcow2_checksum" {
  type        = string
  # Compute with:  sha256sum al2023-kvm-*.qcow2
  # Or fetch the SHA256SUMS file published alongside the image on cdn.amazonlinux.com.
  # Set to "none" only for offline/air-gapped builds where you already verified
  # the image by other means — never skip in production CI.
  default     = "none"
  description = "sha256:<hash> checksum for the source QCOW2. Use 'none' only for local dev."
}

variable "qemu_ssh_password" {
  type        = string
  sensitive   = true
  # This password is only used during the Packer build session to SSH into the
  # ephemeral VM.  It is removed / replaced before the final QCOW2 is sealed.
  # Override via: PACKER_VAR_qemu_ssh_password=... or -var qemu_ssh_password=...
  default     = "tabyaos-packer-build"
  description = "Ephemeral SSH password injected via cloud-init for the build VM."
}

variable "qemu_output_dir" {
  type        = string
  default     = "output/al2023-qcow2"
  description = "Directory where the finished QCOW2 is written."
}

variable "qemu_memory_mb" {
  type        = number
  default     = 2048
  description = "RAM (MiB) allocated to the build VM."
}

variable "qemu_cpus" {
  type        = number
  default     = 2
  description = "vCPU count for the build VM."
}

variable "qemu_accelerator" {
  type        = string
  # kvm  — Linux hosts with KVM enabled (fastest)
  # hvf  — macOS hosts with Apple Hypervisor Framework
  # tcg  — software emulation, any host (slowest, ~10× slower build)
  # none — let QEMU autodetect
  default     = "kvm"
  description = "QEMU accelerator: kvm | hvf | tcg | none."
}
