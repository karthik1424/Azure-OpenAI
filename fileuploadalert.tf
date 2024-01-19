#Resource Group 

resource "azurerm_resource_group" "azure_openai_alerts_rg" {
  name     = "azurem_openai_${local.environment}_${var.location_id}_alerts_rg"
  location = var.location
  tags     = var.standard_tags
}


#Action_group

resource "azurerm_monitor_action_group" "actionGroup" {
resource_group_name = azurerm_resource_group.azure_openai_alerts_rg.name 
     name       = "azurerm_openai_${local.environment}_${var.location_id}_ag_01"
     short_name = "FileuploadAi"
     tags =var.standard_tags
 dynamic "email_receiver" {
   for_each = var.email_receiver
   content {
    name          = email_receiver.key
    email_address = email_receiver.value.email_address
   }
  }
}

# Log Search Alert-rule 

module "logsearch-fileuploadalert" {
source  = "prod-tfe.web.rbsgrp.net/CTO/alert/azurerm"
version = "4.1.0"
tags = var.standard_tags
log_alerts = [
{
  location            = var.location
  resource_group_name = azurerm_resource_group.azure_openai_alerts_rg.name
  name        = "ALERT-FileUpload"
  description = "There is a file upload, delete immediately"

  data_source_id = var.alert_scope
  time_window =5
  trigger_operator = "GreaterThanOrEqual"
  trigger_threshold =1
  action_group =["${azurerm_monitor_action_group.actionGroup.id}"]
  frequency =5

   query                   = "AzureDiagnostics\n|\nwhere OperationName == \"Creates a new file entity by uploading data from a local machine. Uploaded files can, for example, be used for training or evaluating fine-tuned models.\""

   severity                         = 0
   enabled                          = true
 }]
}
