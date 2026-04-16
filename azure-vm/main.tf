resource "azurerm_resource_group" "prod-resource" {
  name = "prod-resource"
  location = "West Europe"
}

resource "azurerm_virtual_network" "prod-vpn" {
    name = "prod-vpn"
    location = azurerm_resource_group.prod-resource.location
    resource_group_name = azurerm_resource_group.prod-resource.name

    address_space = ["10.0.0.6/16"]
}

resource "azurerm_subnet" "public_subnet" {
  name = "public_subnet"
  resource_group_name = azurerm_resource_group.prod-resource.name
  virtual_network_name = azurerm_virtual_network.prod-vpn.name
  address_prefixes = ["10.0.0.0/24"]
}