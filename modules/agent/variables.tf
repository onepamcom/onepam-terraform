variable "server_url" {
  description = "OnePAM server URL"
  type        = string
  default     = "https://onepam.com"
}

variable "tenant_id" {
  description = "Organisation UUID (required)"
  type        = string

  validation {
    condition     = can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.tenant_id))
    error_message = "tenant_id must be a valid UUID."
  }
}

variable "group_uuid" {
  description = "Optional group UUID to assign the agent to"
  type        = string
  default     = ""

  validation {
    condition     = var.group_uuid == "" || can(regex("^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$", var.group_uuid))
    error_message = "group_uuid must be empty or a valid UUID."
  }
}

variable "agent_version" {
  description = "Agent version to install"
  type        = string
  default     = "latest"
}

variable "log_level" {
  description = "Agent log level"
  type        = string
  default     = "info"

  validation {
    condition     = contains(["debug", "info", "warn", "error"], var.log_level)
    error_message = "log_level must be one of: debug, info, warn, error."
  }
}

variable "release_url" {
  description = "Base URL for agent binary downloads"
  type        = string
  default     = "https://updates.onepam.com"
}
