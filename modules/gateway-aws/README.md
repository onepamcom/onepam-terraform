# OnePAM Gateway — AWS Module

Terraform module for deploying an OnePAM Zero Trust Access Gateway on AWS with EC2 Auto Scaling, IAM, security groups, and SSM Parameter Store for secrets.

## Usage

```hcl
module "onepam_gateway" {
  source        = "./modules/gateway-aws"
  vpc_id        = "vpc-0123456789abcdef0"
  subnet_id     = "subnet-0123456789abcdef0"
  gateway_id    = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  api_url       = "wss://onepam.example.com/api/v1/gateway/ws"
  api_token     = var.gateway_api_token
  s3_bucket     = "my-recordings-bucket"
  s3_access_key = var.s3_access_key
  s3_secret_key = var.s3_secret_key
}
```

## Resources Created

- **IAM Role + Instance Profile** — scoped to SSM parameter read and S3 upload
- **Security Group** — HTTPS (443), optional mTLS (9443), optional WireGuard (51820)
- **Launch Template** — Amazon Linux 2023 with cloud-init userdata
- **Auto Scaling Group** — single-instance for self-healing

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `vpc_id` | VPC ID | `string` | — | yes |
| `subnet_id` | Subnet ID (public recommended) | `string` | — | yes |
| `gateway_id` | Gateway UUID from OnePAM | `string` | — | yes |
| `api_url` | WebSocket API URL | `string` | — | yes |
| `api_token` | Per-gateway API token | `string` | — | yes |
| `s3_bucket` | S3 bucket for recordings | `string` | — | yes |
| `s3_access_key` | S3 access key | `string` | — | yes |
| `s3_secret_key` | S3 secret key | `string` | — | yes |
| `instance_type` | EC2 instance type | `string` | `"t4g.small"` | no |
| `architecture` | CPU arch (arm64/amd64) | `string` | `"arm64"` | no |
| `s3_region` | S3 region | `string` | `"us-east-1"` | no |
| `s3_endpoint` | S3-compatible endpoint | `string` | `""` | no |
| `s3_path_style` | Path-style S3 addressing | `bool` | `false` | no |
| `public_domain` | Public FQDN for the gateway | `string` | `""` | no |
| `acme_enabled` | Enable Let's Encrypt TLS | `bool` | `false` | no |
| `acme_email` | ACME contact email | `string` | `""` | no |
| `enable_vpn` | Enable WireGuard VPN | `bool` | `false` | no |
| `enable_mtls` | Enable mTLS listener | `bool` | `true` | no |
| `tags` | Additional resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| `security_group_id` | Security Group ID |
| `autoscaling_group_name` | ASG name |
| `launch_template_id` | Launch Template ID |
| `iam_role_arn` | IAM Role ARN |

## Example

See [`examples/gateway-aws/`](../../examples/gateway-aws/).
