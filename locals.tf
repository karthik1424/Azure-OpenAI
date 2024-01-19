locals {
  vnet_cidr_range       = "10.214.60.0/24"
  subnets_range         = ["10.214.60.0/26, 10.214.60.64/26, 10.214.60.128/26, 10.214.60.192/26"]
  replace_subnet_prefix = replace("${var.subnet_address_prefixes}", "/", "-")
  environment           = var.standard_tags["Environment"]
  azurerm_subnet_name   = "openai-${local.environment}-01-weu-${local.replace_subnet_prefix}-sn"
  azurerm_route_table   = "openai-${local.environment}-01-weu-${local.replace_subnet_prefix}-sn-udr"
  nsg_name              = "openai-${local.environment}-01-weu-${local.replace_subnet_prefix}-sn-nsg"
}

locals {
    location_short_values = {
    westeurope  = "weu"
    uksouth = "uks"
  }
}

locals{
  deployment_conventions ={ 
    gpt-35-turbo = "gpt35"
    text-embedding-ada-002 ="ada002"
    gpt-4 ="gpt4"
    gpt-4-32k ="gpt432k"
    gpt-35-turbo-16k ="gpt35turbo16k"
  }
}
