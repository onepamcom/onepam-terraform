# OnePAM Agent Module

Terraform module that generates a cloud-init script for installing the OnePAM agent on any Linux instance.

This module is **cloud-agnostic** — it produces a bash script that can be passed as `user_data` (AWS), `custom_data` (Azure), or `metadata.startup-script` (GCP).

## Usage

```hcl
module "onepam_agent" {
  source    = "onepamcom/agent/aws"
  tenant_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}

resource "aws_instance" "server" {
  ami           = data.aws_ssm_parameter.ami.value
  instance_type = "t3.micro"
  user_data     = module.onepam_agent.install_script
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `server_url` | OnePAM server URL | `string` | `"https://onepam.com"` | no |
| `tenant_id` | Organisation UUID | `string` | — | yes |
| `group_uuid` | Optional group UUID | `string` | `""` | no |
| `agent_version` | Agent version to install | `string` | `"latest"` | no |
| `log_level` | Agent log level (debug, info, warn, error) | `string` | `"info"` | no |
| `release_url` | Base URL for binary downloads | `string` | `"https://updates.onepam.com"` | no |

## Outputs

| Name | Description |
|------|-------------|
| `install_script` | Cloud-init script that installs and configures the OnePAM agent |

## Examples

- [AWS](../../examples/agent-aws/)
- [Azure](../../examples/agent-azure/)
- [GCP](../../examples/agent-gcp/)
