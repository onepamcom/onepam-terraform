# OnePAM Terraform Modules

[![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?logo=terraform&logoColor=white)](https://registry.terraform.io/modules/onepamcom/agent/aws)
[![License: MPL 2.0](https://img.shields.io/badge/License-MPL_2.0-brightgreen.svg)](https://opensource.org/licenses/MPL-2.0)

Terraform modules for deploying **OnePAM agents** and **gateways** on AWS, GCP, and Azure.

[OnePAM](https://onepam.com) is a unified Zero Trust Privileged Access Management platform providing SSO, session recording, and RBAC for SSH, RDP, VNC, Kubernetes, databases, and more.

## Modules

| Module | Description |
|--------|-------------|
| [`modules/agent`](modules/agent) | Cloud-init script for installing the OnePAM agent on any Linux instance |
| [`modules/gateway-aws`](modules/gateway-aws) | Deploy an OnePAM gateway on AWS EC2 with IAM, security groups, and ASG |

## Quick Start

### Agent (AWS)

```hcl
module "onepam_agent" {
  source    = "onepamcom/agent/aws"
  tenant_id = "YOUR-TENANT-UUID"
}

data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "server" {
  ami           = data.aws_ssm_parameter.ami.value
  instance_type = "t3.micro"
  user_data     = module.onepam_agent.install_script
}
```

### Gateway (AWS)

```hcl
module "onepam_gateway" {
  source        = "./modules/gateway-aws"
  vpc_id        = "vpc-0123456789abcdef0"
  subnet_id     = "subnet-0123456789abcdef0"
  gateway_id    = "YOUR-GATEWAY-UUID"
  api_url       = "wss://onepam.example.com/api/v1/gateway/ws"
  api_token     = var.gateway_api_token
  s3_bucket     = "my-recordings-bucket"
  s3_access_key = var.s3_access_key
  s3_secret_key = var.s3_secret_key
}
```

## Requirements

| Name | Version |
|------|---------|
| Terraform | >= 1.0 |
| AWS Provider | >= 5.0 (for gateway-aws) |

## Documentation

- [OnePAM Terraform Docs](https://onepam.com/docs/install/terraform)
- [Agent Module](modules/agent/README.md)
- [Gateway AWS Module](modules/gateway-aws/README.md)
- [Examples](examples/)

## Support

- Documentation: https://onepam.com/docs
- Email: support@onepam.com
