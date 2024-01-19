variable "sp_app_id" {
  description = "The APP ID to connect to Azure with:"
}

variable "sp_secret" {
  description = "The SP APP ID Secret to connect to Azure with (sensitive value)"
}
variable "rbac_sp_app_id" {
  description = "The APP ID to connect to Azure with for RBAC:"
}

variable "rbac_sp_secret" {
  description = "The RBAC SP APP ID Secret to connect to Azure with (sensitive value)"
}

variable "subscription_id" {
  type        = string
  description = "MANDATORY: The MGNT Subscription ID or GUID"
}

variable "tenant_id" {}

variable "location" {
  description = "The location to deploy the resource."
  default     = "westeurope"
}

variable "location_id" {
  description = "The location to deploy the resource."
  default     = "weu"
}

variable "retention" {
  description = "retention period in days"
  type        = number
  default     = 30
}

variable "standard_tags" {
  description = "A mapping of tags to apply to resources."
}

variable "vnet_name" {}

variable "vnet_id" {}

variable "vnet_rg" {}

variable "azurerm_openai_01_rg_name" {
  type        = string
  description = "Name of the resource group"
  default     = "openai-dev-01-weu-openai-001-rg"
}

variable "create_dns_a_policy_managedidentity_object_ids" {
  type        = list(any)
  description = "OPTIONAL: Azure AD ObjectIdS that will be granted Private DNS Contributor right on the Resource Group where Private Zones are created. If using Azure Policy to create/delete A records will be the Managed Identity used by Policy Assignment"
  default     = []
}

variable "resource_group_name" {
  description = "MANDATORY: Resource group for Private Zone"
  default     = "openai-dev-01-weu-dnspzone-001-rg"
}

variable "subnet_address_prefixes" {
  type = string
}

variable "email_receiver"{
  type =map(any)
 }
variable "alert_scope"{
  type = string
}

variable "model_format"{
  type = string
  default = "OpenAI"
}

variable "model_scale"{
  type = string
  default = "Standard"
}

variable "model_versions" {
  type = map(string)
}

variable "cognitive_accounts" {
  type        = map(any)
  description = "Names of cognitive accounts to be created and OpenAI models to be deployed inside each account"
}
variable "apim_system_managed_identity"{
  type = string
}

variable "udrs"{
  type = list(map(any))
}

variable "nsg_rg"{
    type = string
}

variable "custom_rules"{
    type = list(map(string))
}

variable "apim_law"{
  type = string
}

variable "new_cognitive_accounts"{
  type        = map(any)
}
