provider "azurerm" {
  resource_provider_registrations = "none"  # his is only required when the User, Service Principal, or Identity running Terraform lacks the permissions to register Azure Resource Providers.
  features {}
  subscription_id = "3ace3d7d-20ab-4247-913b-8cf59d7062ad"
}

terraform {
  required_providers {
    azurerm = {
        source  = "hashicorp/azurerm"
        version = "=4.1.0"
    }
  }
}