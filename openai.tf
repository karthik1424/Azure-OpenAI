# Create a resource group
resource "azurerm_resource_group" "azure_openai_rg" {
  for_each = var.cognitive_accounts
  name     = "azurerm_openai_${local.environment}_${local.location_short_values[each.value.location]}_team_${each.key}_rg"
  location = each.value.location
  tags     = merge(var.standard_tags, each.value.openai_tags)
}

# Create a OpenAI resource
resource "azurerm_cognitive_account" "azurerm_openai_cga" {
  for_each                      = var.cognitive_accounts
  name                          = "azurerm_openai_team_${each.key}_cgs"
  location                      = each.value.location
  resource_group_name           = azurerm_resource_group.azure_openai_rg[each.key].name
  kind                          = lookup(each.value,"acc_kind","OpenAI")
  sku_name                      = lookup(each.value,"acc_sku","S0")
  public_network_access_enabled = "false"
  tags                          = merge(var.standard_tags, each.value.openai_tags)
  custom_subdomain_name         = "team-${each.key}-${local.environment}"
}

module "openai_privatelink_weu_dnsrecord" {
  for_each                                   = var.cognitive_accounts
  source                                     = "prod-tfe.web.rbsgrp.net/CTO/private-endpoint/azurerm"
  version                                    = "1.0.4"
  location                                   = var.location
  resource_id                                = azurerm_cognitive_account.azurerm_openai_cga[each.key].id
  vnet_resource_group_name                   = var.vnet_rg
  subnet_id                                  = azurerm_subnet.azurerm_openai_01_sn.id
  tags                                       = merge(var.standard_tags, each.value.openai_tags)
  private_dns_zone_group_private_dns_zone_id = "/subscriptions/a2126a12-528a-480a-9f25-445f1b3c0237/resourceGroups/conn-prd-01-weu-privatezone-001-rg/providers/Microsoft.Network/privateDnsZones/privatelink.openai.azure.com"
}

locals {
  cog_deployments = flatten([
    for acc_key, acc_value in var.cognitive_accounts : [
      for model in acc_value.models : {
        cog_acc               = acc_key
        cognitive_account_id  = azurerm_cognitive_account.azurerm_openai_cga[acc_key].id
        model_name            = model
        version               = var.model_versions[model]
      }
    ]
  ])
}

resource "azurerm_cognitive_deployment" "azurerm_openai_deployment_gpt" {
  for_each = { for value in local.cog_deployments : "team_${value.cog_acc}_${value.model_name}" => value }
  cognitive_account_id = each.value.cognitive_account_id
  name                 = "openai-${each.value.model_name}"
  model {
    format  = var.model_format
    name    = each.value.model_name
    version = each.value.version
  }
  scale {
    type = var.model_scale
    capacity = 3
  }
}
