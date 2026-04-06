locals {
  install_script = templatefile("${path.module}/templates/cloud-init.sh.tftpl", {
    server_url    = var.server_url
    tenant_id     = var.tenant_id
    group_uuid    = var.group_uuid
    agent_version = var.agent_version
    log_level     = var.log_level
    release_url   = var.release_url
  })
}
