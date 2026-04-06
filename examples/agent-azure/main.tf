terraform {
  required_providers {
    azurerm = { source = "hashicorp/azurerm", version = ">= 3.0" }
  }
}

provider "azurerm" {
  features {}
}

module "onepam_agent" {
  source    = "../../modules/agent"
  tenant_id = var.tenant_id
}

resource "azurerm_resource_group" "example" {
  name     = "onepam-example-rg"
  location = "East US"
}

resource "azurerm_linux_virtual_machine" "example" {
  name                = "onepam-example-vm"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_B1s"
  admin_username      = "adminuser"

  custom_data = base64encode(module.onepam_agent.install_script)

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  network_interface_ids = []
}

variable "tenant_id" { type = string }
