resource "azurerm_resource_group" "prod-resource" {
  name = "prod-resource"
  location = "West Europe"
}

resource "azurerm_virtual_network" "prod-vpn" {
    name = "prod-vpn"
    location = azurerm_resource_group.prod-resource.location
    resource_group_name = azurerm_resource_group.prod-resource.name

    address_space = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "public_subnet" {
  name = "public_subnet"
  resource_group_name = azurerm_resource_group.prod-resource.name
  virtual_network_name = azurerm_virtual_network.prod-vpn.name
  address_prefixes = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "private_subnet" {
  name = "private_subnet"
  resource_group_name = azurerm_resource_group.prod-resource.name
  virtual_network_name = azurerm_virtual_network.prod-vpn.name
  address_prefixes = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "public_prodtion_network_sg" {
    name = "public_production_network_sg"
    location = azurerm_resource_group.prod-resource.location
    resource_group_name = azurerm_resource_group.prod-resource.name

    security_rule {
        name = "public_ssh"
        priority = 100
        source_address_prefix = "*"
        source_port_range = "*"
        destination_address_prefix = "*"
        destination_port_range = "22"
        access = "Allow"
        protocol = "Tcp"
        direction = "Inbound"
        description = "This rule is used for ssh useage"
    }
}