variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "eks_version" {
  description = "EKS version to target"
  type        = string
  default     = "1.31"
}

variable "instance_type_x86_64" {
  description = "EC2 instance type for x86_64 build"
  type        = string
  default     = "t3.medium"
}

variable "instance_type_arm64" {
  description = "EC2 instance type for arm64 build"
  type        = string
  default     = "t4g.medium"
}

variable "ami_name_prefix" {
  description = "Prefix for the output AMI name"
  type        = string
  default     = "tabyaos-debian12"
}

variable "encrypt_boot" {
  description = "Encrypt root EBS volume"
  type        = bool
  default     = true
}

variable "volume_size_gb" {
  description = "Root volume size in GB"
  type        = number
  default     = 20
}

variable "subnet_id" {
  description = "Subnet ID for build instance; empty uses default-VPC subnet"
  type        = string
  default     = ""
}

variable "associate_public_ip_address" {
  description = "Assign public IP to build instance"
  type        = bool
  default     = true
}

variable "qemu_accelerator" {
  description = "QEMU accelerator: tcg (universal), kvm (Linux), whpx (Windows 11)"
  type        = string
  default     = "tcg"
}

variable "kms_key_id" {
  description = "KMS key ARN/ID for EBS encryption; empty uses aws/ebs default key"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Extra tags merged onto all resources"
  type        = map(string)
  default     = {}
}
