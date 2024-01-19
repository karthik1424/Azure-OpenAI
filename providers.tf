terraform {
  required_version = ">= 0.13.0" # This is the version bundled with IaC Utilities 3.0
  required_providers {
    # Azure RM currently in IaC 3.0
    azurerm = ">= 3.0.0"

    # Additional providers should be included if applicable
    # NONE
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  client_id       = var.sp_app_id
  client_secret   = var.sp_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id

}

provider "azurerm" {
  alias = "rbac"
  features {
  }
  client_id       = var.rbac_sp_app_id
  client_secret   = var.rbac_sp_secret
  subscription_id = var.subscription_id
  tenant_id       = var.tenant_id
}
