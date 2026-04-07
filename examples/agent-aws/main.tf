terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.0" }
  }
}

provider "aws" {
  region = var.aws_region
}

module "onepam_agent" {
  source    = "../../modules/agent"
  tenant_id = var.tenant_id
}

data "aws_ssm_parameter" "ami" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "example" {
  ami           = data.aws_ssm_parameter.ami.value
  instance_type = "t3.micro"
  user_data     = module.onepam_agent.install_script

  tags = { Name = "onepam-example" }
}

variable "tenant_id" {
  description = "OnePAM tenant UUID"
  type        = string
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}
