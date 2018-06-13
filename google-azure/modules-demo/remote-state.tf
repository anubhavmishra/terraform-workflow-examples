##### Remote state in AzureRM #####
terraform {
  backend "azurerm" {
    resource_group_name  = "demo"
    storage_account_name = "demo"
    container_name       = "terraform-state"
    key                  = "demo.terraform.tfstate"
  }
}
