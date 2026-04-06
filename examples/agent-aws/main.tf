terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.0" }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "onepam_agent" {
  source    = "../../modules/agent"
  tenant_id = var.tenant_id
}

resource "aws_instance" "example" {
  ami           = "ami-0abcdef1234567890"
  instance_type = "t3.micro"
  user_data     = module.onepam_agent.install_script

  tags = { Name = "onepam-example" }
}

variable "tenant_id" {
  description = "OnePAM tenant UUID"
  type        = string
}
