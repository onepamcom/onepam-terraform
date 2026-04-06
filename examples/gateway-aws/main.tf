terraform {
  required_providers {
    aws = { source = "hashicorp/aws", version = ">= 5.0" }
  }
}

provider "aws" {
  region = var.aws_region
}

module "onepam_gateway" {
  source        = "../../modules/gateway-aws"
  vpc_id        = var.vpc_id
  subnet_id     = var.subnet_id
  gateway_id    = var.gateway_id
  api_url       = var.api_url
  api_token     = var.api_token
  s3_bucket     = var.s3_bucket
  s3_access_key = var.s3_access_key
  s3_secret_key = var.s3_secret_key
  s3_region     = var.aws_region
  public_domain = var.public_domain
  acme_enabled  = true
  acme_email    = var.acme_email
  enable_mtls   = true
}

variable "aws_region" { default = "us-east-1" }
variable "vpc_id" { type = string }
variable "subnet_id" { type = string }
variable "gateway_id" { type = string }
variable "api_url" { type = string }
variable "api_token" { type = string; sensitive = true }
variable "s3_bucket" { type = string }
variable "s3_access_key" { type = string; sensitive = true }
variable "s3_secret_key" { type = string; sensitive = true }
variable "public_domain" { type = string; default = "" }
variable "acme_email" { type = string; default = "" }
