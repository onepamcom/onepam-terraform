terraform {
  required_providers {
    google = { source = "hashicorp/google", version = ">= 5.0" }
  }
}

provider "google" {
  project = var.project_id
  region  = "us-central1"
}

module "onepam_agent" {
  source    = "../../modules/agent"
  tenant_id = var.tenant_id
}

resource "google_compute_instance" "example" {
  name         = "onepam-example"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = module.onepam_agent.install_script
}

variable "tenant_id" { type = string }
variable "project_id" { type = string }
