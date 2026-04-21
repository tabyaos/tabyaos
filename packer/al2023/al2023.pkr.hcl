packer {
  required_version = ">= 1.10.0"

  required_plugins {
    amazon = {
      version = ">= 1.3.3"
      source  = "github.com/hashicorp/amazon"
    }
    qemu = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

# ─────────────────────────────────────────────────────────────────────────────
# Locals
# ─────────────────────────────────────────────────────────────────────────────

locals {
  # Merge caller-supplied tags with the standard TabyaOS tags.
  base_tags = merge(
    {
      Project        = "tabyaos"
      EKSVersion     = var.eks_version
      HardeningLevel = "baseline"
      ManagedBy      = "packer"
      # timestamp() is HCL2-native and evaluates at build time.
      # {{timestamp}} only works in ami_name / ami_description fields.
      BuildTimestamp = timestamp()
    },
    var.tags
  )

  # Resolved KMS key — null tells Packer to use the default aws/ebs key.
  kms_key = var.kms_key_id != "" ? var.kms_key_id : null
}

# ─────────────────────────────────────────────────────────────────────────────
# Sources
# ─────────────────────────────────────────────────────────────────────────────

source "amazon-ebs" "al2023-x86_64" {
  region = var.aws_region

  # AWS publishes EKS-optimised AL2023 AMIs under the "amazon" account.
  # Using the EKS-optimised base means kubelet, containerd, and the
  # /etc/eks/bootstrap.sh script are already present — hardening layers on top.
  source_ami_filter {
    filters = {
      name                = "amazon-eks-node-al2023-x86_64-standard-${var.eks_version}-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      architecture        = "x86_64"
      state               = "available"
    }
    owners      = ["amazon"]
    most_recent = true
  }

  instance_type               = var.instance_type_x86_64
  subnet_id                   = var.subnet_id != "" ? var.subnet_id : null
  associate_public_ip_address = var.associate_public_ip_address

  ami_name        = "${var.ami_name_prefix}-x86_64-eks${var.eks_version}-{{timestamp}}"
  ami_description = "TabyaOS AL2023 x86_64 — EKS ${var.eks_version} baseline (unhardened)"

  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_size           = var.volume_size_gb
    volume_type           = "gp3"
    throughput            = 125
    iops                  = 3000
    delete_on_termination = true
    encrypted             = var.encrypt_boot
    kms_key_id            = local.kms_key
  }

  tags           = merge(local.base_tags, { Architecture = "x86_64", Name = "${var.ami_name_prefix}-x86_64-eks${var.eks_version}" })
  snapshot_tags  = merge(local.base_tags, { Architecture = "x86_64" })

  communicator = "ssh"
  ssh_username = "ec2-user"

  shutdown_behavior            = "terminate"
  force_deregister             = false
  force_delete_snapshot        = false
}

source "amazon-ebs" "al2023-arm64" {
  region = var.aws_region

  source_ami_filter {
    filters = {
      name                = "amazon-eks-node-al2023-arm64-standard-${var.eks_version}-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      architecture        = "arm64"
      state               = "available"
    }
    owners      = ["amazon"]
    most_recent = true
  }

  instance_type               = var.instance_type_arm64
  subnet_id                   = var.subnet_id != "" ? var.subnet_id : null
  associate_public_ip_address = var.associate_public_ip_address

  ami_name        = "${var.ami_name_prefix}-arm64-eks${var.eks_version}-{{timestamp}}"
  ami_description = "TabyaOS AL2023 arm64 — EKS ${var.eks_version} baseline (unhardened)"

  launch_block_device_mappings {
    device_name           = "/dev/xvda"
    volume_size           = var.volume_size_gb
    volume_type           = "gp3"
    throughput            = 125
    iops                  = 3000
    delete_on_termination = true
    encrypted             = var.encrypt_boot
    kms_key_id            = local.kms_key
  }

  tags           = merge(local.base_tags, { Architecture = "arm64", Name = "${var.ami_name_prefix}-arm64-eks${var.eks_version}" })
  snapshot_tags  = merge(local.base_tags, { Architecture = "arm64" })

  communicator = "ssh"
  ssh_username = "ec2-user"

  shutdown_behavior     = "terminate"
  force_deregister      = false
  force_delete_snapshot = false
}

# ─────────────────────────────────────────────────────────────────────────────
# Build
# ─────────────────────────────────────────────────────────────────────────────

build {
  name = "tabyaos-al2023"

  sources = [
    "source.amazon-ebs.al2023-x86_64",
    "source.amazon-ebs.al2023-arm64",
  ]

  # Ensure the instance can reach package mirrors before doing anything else.
  provisioner "shell" {
    inline = [
      "sudo cloud-init status --wait || true",
    ]
    pause_before = "10s"
  }

  # Apply pending security updates only — no hardening at this stage.
  provisioner "shell" {
    inline = [
      "sudo dnf update -y --security",
      "sudo dnf clean all",
    ]
  }

  # Smoke-check: verify the EKS bootstrap artefacts are present.
  # If any of these fail the AMI is not EKS-join-capable and the build aborts.
  provisioner "shell" {
    inline = [
      "echo '=== EKS bootstrap check ==='",
      "test -f /etc/eks/bootstrap.sh || (echo 'FAIL: /etc/eks/bootstrap.sh missing' && exit 1)",
      "kubelet --version",
      "containerd --version",
      "echo '=== SSM agent check ==='",
      "systemctl is-enabled amazon-ssm-agent",
      "echo '=== Baseline OK ==='",
    ]
  }

  # Record build provenance inside the image.
  provisioner "shell" {
    inline = [
      "echo \"TabyaOS AL2023 baseline — built $(date -u +%Y-%m-%dT%H:%M:%SZ)\" | sudo tee /etc/tabyaos-release",
      "echo \"EKSVersion=${var.eks_version}\" | sudo tee -a /etc/tabyaos-release",
      "echo \"HardeningLevel=baseline\" | sudo tee -a /etc/tabyaos-release",
    ]
  }
}
