packer {
  required_version = ">= 1.10.0"

  required_plugins {
    amazon = {
      version = ">= 1.3.3"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

locals {
  base_tags = merge(
    {
      Project        = "tabyaos"
      BaseOS         = "rhel9"
      EKSVersion     = var.eks_version
      HardeningLevel = "cis_l2+pci_dss+soc2"
      ManagedBy      = "packer"
      BuildTimestamp = timestamp()
    },
    var.tags
  )

  kms_key = var.kms_key_id != "" ? var.kms_key_id : null
}

# ─────────────────────────────────────────────────────────────────────────────
# Sources
# ─────────────────────────────────────────────────────────────────────────────

source "amazon-ebs" "rhel9-x86_64" {
  region = var.aws_region

  # Red Hat official account publishes RHEL 9 AMIs.
  source_ami_filter {
    filters = {
      name                = "RHEL-9.*_HVM-*-x86_64-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      architecture        = "x86_64"
      state               = "available"
    }
    owners      = ["309956199498"]
    most_recent = true
  }

  instance_type               = var.instance_type_x86_64
  ssh_username                = "ec2-user"
  ssh_timeout                 = "15m"
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address

  ami_name        = "${var.ami_name_prefix}-x86_64-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  ami_description = "TabyaOS RHEL 9 hardened node image (x86_64) — CIS L2 + PCI-DSS v4.0 + SOC2"

  encrypt_boot = var.encrypt_boot
  kms_key_id   = local.kms_key

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = var.volume_size_gb
    volume_type           = "gp3"
    throughput            = 125
    iops                  = 3000
    delete_on_termination = true
    encrypted             = var.encrypt_boot
    kms_key_id            = local.kms_key
  }

  tags          = local.base_tags
  run_tags      = local.base_tags
  snapshot_tags = local.base_tags
}

source "amazon-ebs" "rhel9-arm64" {
  region = var.aws_region

  source_ami_filter {
    filters = {
      name                = "RHEL-9.*_HVM-*-arm64-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      architecture        = "arm64"
      state               = "available"
    }
    owners      = ["309956199498"]
    most_recent = true
  }

  instance_type               = var.instance_type_arm64
  ssh_username                = "ec2-user"
  ssh_timeout                 = "15m"
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address

  ami_name        = "${var.ami_name_prefix}-arm64-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  ami_description = "TabyaOS RHEL 9 hardened node image (arm64) — CIS L2 + PCI-DSS v4.0 + SOC2"

  encrypt_boot = var.encrypt_boot
  kms_key_id   = local.kms_key

  launch_block_device_mappings {
    device_name           = "/dev/sda1"
    volume_size           = var.volume_size_gb
    volume_type           = "gp3"
    throughput            = 125
    iops                  = 3000
    delete_on_termination = true
    encrypted             = var.encrypt_boot
    kms_key_id            = local.kms_key
  }

  tags          = local.base_tags
  run_tags      = local.base_tags
  snapshot_tags = local.base_tags
}

# ─────────────────────────────────────────────────────────────────────────────
# Build
# ─────────────────────────────────────────────────────────────────────────────

build {
  name = "tabyaos-rhel9"

  sources = [
    "source.amazon-ebs.rhel9-x86_64",
    "source.amazon-ebs.rhel9-arm64",
  ]

  # Bootstrap: ensure Python 3 is available for Ansible
  provisioner "shell" {
    inline = [
      "sudo dnf install -y python3 python3-dnf",
    ]
  }

  provisioner "ansible" {
    playbook_file = "${path.root}/../../ansible/playbooks/harden-rhel9.yml"
    user          = "ec2-user"
    extra_arguments = [
      "--extra-vars", "ansible_python_interpreter=/usr/bin/python3",
      "--extra-vars", "tabyaos_base_os=rhel9",
      "--extra-vars", "eks_version=${var.eks_version}",
    ]
    ansible_env_vars = [
      "ANSIBLE_HOST_KEY_CHECKING=False",
      "ANSIBLE_STDOUT_CALLBACK=default",
    ]
  }

  post-processor "manifest" {
    output     = "output/rhel9-manifest.json"
    strip_path = true
  }
}
