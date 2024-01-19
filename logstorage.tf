resource "azurerm_resource_group" "azure_logarchive_rg" {
  name     = "azurerm_openai_${local.environment}_${var.location_id}_logstorage_101_rg"
  location = var.location
  tags     = var.standard_tags
}

resource "azurerm_storage_account" "azure_openai_storage_account" {
  name                = "openai${local.environment}${var.location_id}01lasa"
  resource_group_name = azurerm_resource_group.azure_logarchive_rg.name
  location            = var.location
  tags                = var.standard_tags

  access_tier              = "Hot"
  account_kind             = "StorageV2"
  account_replication_type = "LRS"
  account_tier             = "Standard"

  allow_nested_items_to_be_public  = false
  public_network_access_enabled    = true
  cross_tenant_replication_enabled = false
  enable_https_traffic_only        = true
  min_tls_version                  = "TLS1_2"
  shared_access_key_enabled        = true

  network_rules {
    default_action             = "Deny"
    ip_rules                   = ["155.136.158.39", "155.136.158.40", "155.136.158.41", "155.136.158.42"]
    virtual_network_subnet_ids = []
    bypass                     = ["AzureServices"]
  }
}

resource "azurerm_monitor_diagnostic_setting" "azure_openai_mds_sa" {
  for_each                   = var.cognitive_accounts  
  name                       = "azurerm_openai_${local.environment}_${var.location_id}_01_mds_sa" 
  target_resource_id         = azurerm_cognitive_account.azurerm_openai_cga[each.key].id
  storage_account_id         = azurerm_storage_account.azure_openai_storage_account.id

  enabled_log {
    category_group = "allLogs"

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "openai_mds_sa" {
  for_each                   = var.new_cognitive_accounts  
  name                       = "azurerm_openai_${local.environment}_${local.location_short_values[each.value.location]}_01_mds_sa" 
  target_resource_id         = azurerm_cognitive_account.openai_cga[each.key].id
  storage_account_id         = azurerm_storage_account.azure_openai_storage_account.id

  enabled_log {
    category_group = "allLogs"

    retention_policy {
      days    = 0
      enabled = false
    }
  }

  metric {
    category = "AllMetrics"

    retention_policy {
      enabled = false
    }
  }
}
