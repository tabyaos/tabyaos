variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "AWS region in which to build the AMI."
}

variable "eks_version" {
  type        = string
  default     = "1.31"
  description = "EKS version string used to select the source AMI and tag outputs."
}

variable "instance_type_x86_64" {
  type        = string
  default     = "t3.medium"
  description = "EC2 instance type used for the x86_64 build instance."
}

variable "instance_type_arm64" {
  type        = string
  default     = "t4g.medium"
  description = "EC2 instance type used for the arm64 build instance."
}

variable "subnet_id" {
  type        = string
  default     = ""
  description = "Subnet ID for the build instance. Empty string lets Packer choose the default-VPC subnet."
}

variable "ami_name_prefix" {
  type        = string
  default     = "tabyaos-al2023"
  description = "Prefix for the output AMI name. A timestamp is appended automatically."
}

variable "encrypt_boot" {
  type        = bool
  default     = true
  description = "Encrypt the root EBS volume. Uses the default AWS-managed key unless kms_key_id is set."
}

variable "kms_key_id" {
  type        = string
  default     = ""
  description = "Optional CMK ARN for boot volume encryption. Leave empty to use the default aws/ebs key."
}

variable "volume_size_gb" {
  type        = number
  default     = 20
  description = "Root volume size in GiB. 20 GiB is the EKS-optimised AMI default."
}

variable "associate_public_ip_address" {
  type        = bool
  default     = true
  description = "Associate a public IP with the build instance. Set false if the subnet routes via NAT."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Extra key/value tags merged onto every AMI and snapshot."
}
