# Default variable overrides for local / CI builds.
# Commit this file. Secrets (KMS key ARN, subnet IDs) go in environment
# variables or a local vars/local.pkrvars.hcl that is git-ignored.

aws_region   = "us-east-1"
eks_version  = "1.31"

instance_type_x86_64 = "t3.medium"
instance_type_arm64  = "t4g.medium"

ami_name_prefix = "tabyaos-debian12"
encrypt_boot    = true
volume_size_gb  = 20

subnet_id                   = ""
associate_public_ip_address = true

# tcg works everywhere; set to "kvm" (Linux) or "whpx" (Windows 11) for speed
qemu_accelerator = "tcg"

kms_key_id = ""

tags = {}
