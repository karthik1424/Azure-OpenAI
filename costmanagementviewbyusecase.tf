resource "azurerm_subscription_cost_management_view" "azure_openai_cost_view_by_use_case" {
  name         = "azurerm-openai-${local.environment}-${var.location_id}-01-cost-view-by-use-case"
  display_name = "Cost View per Use Case"
  chart_type   = "Area"
  accumulated  = true

  subscription_id = "/subscriptions/${var.subscription_id}"

  report_type = "Usage"
  timeframe   = "MonthToDate"

  dataset {
    granularity = "Monthly"

    aggregation {
      name        = "totalCost"
      column_name = "Cost"
    }

    grouping {
      type = "TagKey"
      name = "Use_Case"
    }

    sorting {
      direction = "Ascending"
      name      = "UsageDate"
    }
  }

  pivot {
    type = "Dimension"
    name = "ServiceName"
  }

  pivot {
    type = "Dimension"
    name = "ResourceLocation"
  }

  pivot {
    type = "Dimension"
    name = "ResourceGroupName"
  }

  kpi {
    type = "Forecast"
  }
}
