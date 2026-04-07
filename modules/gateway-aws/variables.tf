variable "vpc_id" {
  description = "VPC ID where the gateway will be deployed"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID (public subnet recommended for ACME/VPN)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type (>= 2 GiB RAM recommended)"
  type        = string
  default     = "t4g.small"
}

variable "architecture" {
  description = "CPU architecture — must match instance_type family (t4g = arm64, t3 = amd64)"
  type        = string
  default     = "arm64"

  validation {
    condition     = contains(["arm64", "amd64"], var.architecture)
    error_message = "architecture must be arm64 or amd64."
  }
}

variable "gateway_id" {
  description = "Gateway UUID from the OnePAM web UI or API"
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.gateway_id))
    error_message = "gateway_id must be a valid UUID."
  }
}

variable "api_url" {
  description = "WebSocket URL of the OnePAM API (e.g. wss://onepam.example.com/api/v1/gateway/ws)"
  type        = string
}

variable "api_token" {
  description = "Per-gateway API token"
  type        = string
  sensitive   = true
}

variable "s3_bucket" {
  description = "S3 bucket for session recordings"
  type        = string
}

variable "s3_access_key" {
  description = "S3 access key for recording uploads"
  type        = string
  sensitive   = true
}

variable "s3_secret_key" {
  description = "S3 secret key for recording uploads"
  type        = string
  sensitive   = true
}

variable "s3_region" {
  description = "S3 region"
  type        = string
  default     = "us-east-1"
}

variable "s3_endpoint" {
  description = "S3-compatible endpoint URL (leave empty for AWS S3)"
  type        = string
  default     = ""
}

variable "s3_path_style" {
  description = "Use path-style S3 addressing (required for MinIO, Cloudflare R2)"
  type        = bool
  default     = false
}

variable "public_domain" {
  description = "Public FQDN for the gateway (used for ACME, web app URLs, VPN)"
  type        = string
  default     = ""
}

variable "acme_enabled" {
  description = "Enable automatic Let's Encrypt TLS certificates"
  type        = bool
  default     = false
}

variable "acme_email" {
  description = "Contact email for ACME registration"
  type        = string
  default     = ""
}

variable "enable_vpn" {
  description = "Enable the WireGuard VPN server (UDP 51820)"
  type        = bool
  default     = false
}

variable "enable_mtls" {
  description = "Enable mTLS listener on port 9443 for agent/client tunnels"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Additional tags for all resources"
  type        = map(string)
  default     = {}
}
