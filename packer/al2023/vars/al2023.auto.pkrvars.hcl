# Default variable overrides for a local / CI build.
# Commit this file. Secrets (KMS key ARN, specific subnet IDs) belong in
# environment variables or a local vars/local.pkrvars.hcl that is git-ignored.

aws_region   = "us-east-1"
eks_version  = "1.31"

instance_type_x86_64 = "t3.medium"
instance_type_arm64  = "t4g.medium"

ami_name_prefix = "tabyaos-al2023"
encrypt_boot    = true
volume_size_gb  = 20

# Leave subnet_id empty to let Packer use the default-VPC default subnet.
# Override from CLI:  --var subnet_id=subnet-xxxxxxxx
subnet_id = ""

associate_public_ip_address = true
