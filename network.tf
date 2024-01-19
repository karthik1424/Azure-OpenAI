# create a subnet 
resource "azurerm_subnet" "azurerm_openai_01_sn" {
  name                                      = local.azurerm_subnet_name
  resource_group_name                       = var.vnet_rg
  virtual_network_name                      = var.vnet_name
  address_prefixes                          = [var.subnet_address_prefixes]
  private_endpoint_network_policies_enabled = "true"
}

#UDR's 

resource "azurerm_route_table" "rt_tbl" {
  name                          = local.azurerm_route_table
  location                      = var.location
  resource_group_name           = var.vnet_rg
  disable_bgp_route_propagation = true
  tags                          = var.standard_tags
}

resource "azurerm_route" "udr" {
  for_each                = {for route in var.udrs : route.name => route}
  resource_group_name     = var.vnet_rg
  route_table_name        = azurerm_route_table.rt_tbl.name
  name                    = each.value.name
  address_prefix          = each.value.address_prefix
  next_hop_type           = lookup(each.value,"next_hop_type","VirtualAppliance")
  next_hop_in_ip_address  = each.value.next_hop_in_ip_address
}

resource "azurerm_subnet_route_table_association" "rt_tbl_assoc" {
  subnet_id      = azurerm_subnet.azurerm_openai_01_sn.id
  route_table_id = azurerm_route_table.rt_tbl.id
}

#NSG's 

module "nsg" {
   source  = "prod-tfe.web.rbsgrp.net/CTO/nsg/azurerm"
   version = "1.0.7"

   name                 = local.nsg_name
   resource_group_name  = azurerm_resource_group.azure_openai_nsg_rg.name
   location             = var.location
   custom_rules         = var.custom_rules
   tags                 = var.standard_tags
 }

 resource "azurerm_resource_group" "azure_openai_nsg_rg" { 
  name     = var.nsg_rg
  location = var.location
  tags     = var.standard_tags
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.azurerm_openai_01_sn.id
  network_security_group_id = module.nsg.id

}
