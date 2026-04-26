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
      BaseOS         = "debian12"
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

source "amazon-ebs" "debian12-x86_64" {
  region = var.aws_region

  # Debian official account publishes Debian 12 AMIs.
  source_ami_filter {
    filters = {
      name                = "debian-12-amd64-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      architecture        = "x86_64"
      state               = "available"
    }
    owners      = ["136693071363"]
    most_recent = true
  }

  instance_type               = var.instance_type_x86_64
  ssh_username                = "admin"
  ssh_timeout                 = "10m"
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address

  ami_name        = "${var.ami_name_prefix}-x86_64-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  ami_description = "TabyaOS Debian 12 hardened node image (x86_64) — CIS L2 + PCI-DSS v4.0 + SOC2"

  encrypt_boot = var.encrypt_boot
  kms_key_id   = local.kms_key

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

  tags        = local.base_tags
  run_tags    = local.base_tags
  snapshot_tags = local.base_tags
}

source "amazon-ebs" "debian12-arm64" {
  region = var.aws_region

  source_ami_filter {
    filters = {
      name                = "debian-12-arm64-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
      architecture        = "arm64"
      state               = "available"
    }
    owners      = ["136693071363"]
    most_recent = true
  }

  instance_type               = var.instance_type_arm64
  ssh_username                = "admin"
  ssh_timeout                 = "10m"
  subnet_id                   = var.subnet_id
  associate_public_ip_address = var.associate_public_ip_address

  ami_name        = "${var.ami_name_prefix}-arm64-${formatdate("YYYYMMDD-hhmmss", timestamp())}"
  ami_description = "TabyaOS Debian 12 hardened node image (arm64) — CIS L2 + PCI-DSS v4.0 + SOC2"

  encrypt_boot = var.encrypt_boot
  kms_key_id   = local.kms_key

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

  tags        = local.base_tags
  run_tags    = local.base_tags
  snapshot_tags = local.base_tags
}

# QEMU/KVM for local on-prem testing — uses Debian cloud image (no ISO preseed needed)
source "qemu" "debian12-qcow2" {
  iso_url      = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
  iso_checksum = "file:https://cloud.debian.org/images/cloud/bookworm/latest/SHA512SUMS"
  disk_image   = true   # input is already a qcow2, not an ISO

  output_directory = "output/debian12-qcow2"
  vm_name          = "${var.ami_name_prefix}-debian12-x86_64-${formatdate("YYYYMMDD", timestamp())}.qcow2"
  format           = "qcow2"
  disk_size        = "${var.volume_size_gb * 1024}"
  memory           = 2048
  cpus             = 2
  accelerator      = var.qemu_accelerator

  ssh_username    = "debian"
  ssh_password    = "packer"
  ssh_timeout     = "10m"
  headless        = true

  # Cloud-init seed ISO to inject credentials for the first boot
  cd_files     = ["${path.root}/cloud-init/user-data", "${path.root}/cloud-init/meta-data"]
  cd_label     = "cidata"
}

# ─────────────────────────────────────────────────────────────────────────────
# Build
# ─────────────────────────────────────────────────────────────────────────────

build {
  name = "tabyaos-debian12"

  sources = [
    "source.amazon-ebs.debian12-x86_64",
    "source.amazon-ebs.debian12-arm64",
    "source.qemu.debian12-qcow2",
  ]

  # Bootstrap: install Python (required by Ansible) and set up sudo
  provisioner "shell" {
    inline = [
      "sudo apt-get update -qq",
      "sudo apt-get install -y python3 python3-apt sudo curl",
    ]
  }

  provisioner "ansible" {
    playbook_file = "${path.root}/../../ansible/playbooks/harden.yml"
    user          = "admin"
    extra_arguments = [
      "--extra-vars", "ansible_python_interpreter=/usr/bin/python3",
      "--extra-vars", "tabyaos_base_os=debian12",
      "--extra-vars", "eks_version=${var.eks_version}",
    ]
    ansible_env_vars = [
      "ANSIBLE_HOST_KEY_CHECKING=False",
      "ANSIBLE_STDOUT_CALLBACK=default",
    ]
  }

  post-processor "manifest" {
    output     = "output/debian12-manifest.json"
    strip_path = true
  }
}
