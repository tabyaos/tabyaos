# TabyaOS Packer Builds

Packer HCL2 configurations for building hardened Kubernetes node AMIs based on Amazon Linux 2023.

All builds start from the official **AWS EKS-optimised AL2023 AMI** (published by `amazon`) so that `kubelet`, `containerd`, and `/etc/eks/bootstrap.sh` are already present. TabyaOS layers CIS L2 / PCI-DSS / SOC 2 hardening on top — but not yet in the `baseline` build.

## Directory layout

```
packer/
├── README.md              ← this file
└── al2023/
    ├── al2023.pkr.hcl     ← sources + build block
    ├── variables.pkr.hcl  ← all variable declarations
    └── vars/
        └── al2023.auto.pkrvars.hcl   ← committed defaults
```

## Prerequisites

| Tool | Minimum version | Install |
|------|----------------|---------|
| [Packer](https://developer.hashicorp.com/packer/install) | 1.10.0 | `brew install packer` |
| [just](https://just.systems) | any | `brew install just` |
| AWS CLI | v2 | [docs](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) |

## AWS credentials

Packer reads credentials from the standard AWS credential chain:

```
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...
export AWS_SESSION_TOKEN=...          # if using assumed role / SSO
export AWS_DEFAULT_REGION=us-east-1  # overrides the var default
```

For CI, GitHub Actions uses OIDC authentication; see `.github/workflows/build.yml`.

The IAM principal running the build needs these permissions at minimum:

```json
{
  "Effect": "Allow",
  "Action": [
    "ec2:RunInstances",
    "ec2:TerminateInstances",
    "ec2:DescribeInstances",
    "ec2:StopInstances",
    "ec2:DescribeRegions",
    "ec2:DescribeSubnets",
    "ec2:DescribeSecurityGroups",
    "ec2:DescribeImages",
    "ec2:DescribeVolumes",
    "ec2:DescribeSnapshots",
    "ec2:CreateImage",
    "ec2:RegisterImage",
    "ec2:DeregisterImage",
    "ec2:CopyImage",
    "ec2:CreateSnapshot",
    "ec2:DeleteSnapshot",
    "ec2:CreateTags",
    "ec2:CreateKeyPair",
    "ec2:DeleteKeyPair",
    "iam:PassRole"
  ],
  "Resource": "*"
}
```

If `encrypt_boot = true` (default), add `kms:CreateGrant`, `kms:DescribeKey` for the relevant key.

## Running locally

```bash
# 1. Download the amazon Packer plugin
packer init packer/al2023

# 2. Validate the configuration
just validate

# 3. Build both architectures
just build

# 4. Build x86_64 only (faster for local iteration)
just build-x86

# 5. Build against a specific EKS version
just build-eks-version 1.32
```

To override any variable at the command line:

```bash
packer build \
  -var aws_region=eu-west-1 \
  -var subnet_id=subnet-0123456789abcdef0 \
  -var encrypt_boot=false \
  -var-file=packer/al2023/vars/al2023.auto.pkrvars.hcl \
  packer/al2023
```

To skip boot encryption during local iteration (avoids needing KMS access):

```bash
packer build -var encrypt_boot=false packer/al2023
```

## Verifying the resulting AMI joins EKS

After a successful build, launch a node group using the output AMI ID and confirm it reaches `Ready` state:

```bash
# Create a managed node group pointing at the new AMI
aws eks create-nodegroup \
  --cluster-name <your-cluster> \
  --nodegroup-name tabyaos-baseline-test \
  --ami-type CUSTOM \
  --launch-template '{"id":"<your-launch-template-id>"}' \
  --scaling-config minSize=1,maxSize=1,desiredSize=1

# Watch the node appear
kubectl get nodes -w
```

The EKS bootstrap script (`/etc/eks/bootstrap.sh`) is invoked via the launch template user-data:

```bash
#!/bin/bash
/etc/eks/bootstrap.sh <cluster-name> \
  --kubelet-extra-args '--node-labels=tabyaos.io/hardening-level=baseline'
```

## Variables reference

| Variable | Default | Description |
|----------|---------|-------------|
| `aws_region` | `us-east-1` | Build region |
| `eks_version` | `1.31` | EKS version for source AMI filter |
| `instance_type_x86_64` | `t3.medium` | Build instance type (x86_64) |
| `instance_type_arm64` | `t4g.medium` | Build instance type (arm64) |
| `subnet_id` | `""` | VPC subnet for build instance (empty = default VPC) |
| `ami_name_prefix` | `tabyaos-al2023` | AMI name prefix |
| `encrypt_boot` | `true` | Encrypt root EBS volume |
| `kms_key_id` | `""` | CMK ARN; empty uses `aws/ebs` default key |
| `volume_size_gb` | `20` | Root volume size in GiB |
| `associate_public_ip_address` | `true` | Assign public IP to build instance |
| `tags` | `{}` | Extra tags merged onto AMI and snapshot |

## What comes next

This configuration is **unhardened** — it serves as the baseline to measure against before any CIS / PCI-DSS / SOC 2 controls are applied.

Next step: run `kube-bench` against a node launched from this AMI and capture the raw score as the pre-hardening baseline. See `tests/kube-bench/`.
