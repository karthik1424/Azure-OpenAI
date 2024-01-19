# Create a resource group
resource "azurerm_resource_group" "openai_rg" {
  for_each = var.new_cognitive_accounts
  name     = "OpenAI_${each.value.name}_${local.environment}_${local.location_short_values[each.value.location]}_rg"
  location = each.value.location
  tags     = merge(var.standard_tags, each.value.openai_tags)
}

# Create a OpenAI resource
resource "azurerm_cognitive_account" "openai_cga" {
  for_each                      = var.new_cognitive_accounts
  name                          = "OpenAI_${each.value.name}_${local.environment}_${local.location_short_values[each.value.location]}_cgs"
  location                      = each.value.location
  resource_group_name           = azurerm_resource_group.openai_rg[each.key].name
  kind                          = lookup(each.value,"acc_kind","OpenAI")
  sku_name                      = lookup(each.value,"acc_sku","S0")
  public_network_access_enabled = "false"
  tags                          = merge(var.standard_tags, each.value.openai_tags)
  custom_subdomain_name         = "${each.value.name}-${local.environment}-${local.location_short_values[each.value.location]}"
}

module "openai_weuprivatelink_dnsrecord" {
  for_each                                   = var.new_cognitive_accounts
  source                                     = "prod-tfe.web.rbsgrp.net/CTO/private-endpoint/azurerm"
  version                                    = "1.0.4"
  location                                   = var.location
  resource_id                                = azurerm_cognitive_account.openai_cga[each.key].id
  vnet_resource_group_name                   = var.vnet_rg
  subnet_id                                  = azurerm_subnet.azurerm_openai_01_sn.id
  tags                                       = merge(var.standard_tags, each.value.openai_tags)
  private_dns_zone_group_private_dns_zone_id = "/subscriptions/a2126a12-528a-480a-9f25-445f1b3c0237/resourceGroups/conn-prd-01-weu-privatezone-001-rg/providers/Microsoft.Network/privateDnsZones/privatelink.openai.azure.com"
}

locals {
  new_cog_deployments = flatten([
    for acc_key, acc_value in var.new_cognitive_accounts : {
        cog_acc               = acc_key
        cognitive_account_id  = azurerm_cognitive_account.openai_cga[acc_key].id
        model_name            = acc_value.models.name
        version               = var.model_versions[acc_value.models.name]
        capacity              = acc_value.models.capacity    
    }
  ])
}

resource "azurerm_cognitive_deployment" "openai_deployment" {
  for_each = { for value in local.new_cog_deployments : ("${value.cog_acc}_${value.model_name}") => value }
  cognitive_account_id = each.value.cognitive_account_id
  name                 = "${local.deployment_conventions[each.value.model_name]}_${each.value.version}"
  model {
    format  = var.model_format
    name    = each.value.model_name
    version = each.value.version
  }
  scale {
    type = var.model_scale
    capacity = each.value.capacity
  }
}
