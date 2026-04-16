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

resource "azurerm_public_ip" "prod_public_ip" {
    name = "prod_public_ip_address"
    location = azurerm_resource_group.prod-resource.location
    resource_group_name = azurerm_resource_group.prod-resource.name
    allocation_method = "Static"
    
    tags = {
        environment = "Production"
    }
}

resource "azurerm_network_interface" "prod_nic" {
    name = "prod_nic"
    location = azurerm_resource_group.prod-resource.location
    resource_group_name = azurerm_resource_group.prod-resource.name

    ip_configuration {
      name = "internal"
      subnet_id = azurerm_subnet.public_subnet.id
      private_ip_address_allocation = "Dynamic"
      public_ip_address_id = azurerm_public_ip.prod_public_ip.id
    }
}

resource "azurerm_linux_virtual_machine" "public_vm" {
    name = "public_prod_vm"
    resource_group_name = azurerm_resource_group.prod-resource.name
    location = azurerm_resource_group.prod-resource.location
    size = "Standard F2"

    admin_username = "adminuser"

    network_interface_ids = [
        azurerm_network_interface.prod_nic.id
    ]

    admin_ssh_key {
      username = "adminuser"
      public_key = file("azure_key.pub")
    }

    os_disk {
      caching = "ReadWrite"
      storage_account_type = "Standard_LRS"
    }

    source_image_reference {
          publisher = "Canonical"
            offer     = "0001-com-ubuntu-server-jammy"
            sku       = "22_04-lts"
            version   = "latest"
    }  
 
}
