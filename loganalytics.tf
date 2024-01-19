resource "azurerm_log_analytics_workspace" "azure_openai_log_analytics_workspace" {
  name                = "azurerm-openai-${local.environment}-${var.location_id}-01-laws"
  location            = var.location
  resource_group_name = azurerm_resource_group.azure_openai_laws_rg.name
  retention_in_days   = var.retention
  tags                = var.standard_tags
}

resource "azurerm_resource_group" "azure_openai_laws_rg" {
  name     = "azurem_openai_${local.environment}_${var.location_id}_laws_101_rg"
  location = var.location
  tags     = var.standard_tags
}

resource "azurerm_monitor_diagnostic_setting" "azure_openai_mds_laws" {
  for_each                   = var.cognitive_accounts  
  name                       = "azurerm_openai_${local.environment}_${var.location_id}_01_mds_laws" 
  target_resource_id         = azurerm_cognitive_account.azurerm_openai_cga[each.key].id
  log_analytics_workspace_id = var.apim_law
  
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

resource "azurerm_monitor_diagnostic_setting" "openai_mds_laws" {
  for_each                   = var.new_cognitive_accounts  
  name                       = "azurerm_openai_${local.environment}_${local.location_short_values[each.value.location]}_01_mds_laws" 
  target_resource_id         = azurerm_cognitive_account.openai_cga[each.key].id
  log_analytics_workspace_id = var.apim_law
  
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
