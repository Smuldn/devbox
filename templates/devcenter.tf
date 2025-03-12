provider "azurerm" {
    features {}
}

data "terraform_remote_state" "parameters" {
    backend = "local"

    config = {
        path = "${path.module}/terraform/devcenter.tfstate"
    }
}

variable "resource_group_name" {
    description = "The name of the resource group"
    type        = string
}

variable "location" {
    description = "The location of the resources"
    type        = string
}

variable "dev_center_name" {
    description = "The name of the Dev Center"
    type        = string
}

variable "dev_center_project_name" {
    description = "The name of the Dev Center Project"
    type        = string
}

variable "dev_center_pool_name" {
    description = "The name of the Dev Center Pool"
    type        = string
}

resource "azurerm_resource_group" "devcenter_rg" {
    name     = var.resource_group_name
    location = var.location
}

resource "azurerm_dev_center" "devcenter" {
    name                = var.dev_center_name
    resource_group_name = azurerm_resource_group.devcenter_rg.name
    location            = azurerm_resource_group.devcenter_rg.location
}

resource "azurerm_dev_center_project" "devcenter_project" {
    name                = var.dev_center_project_name
    dev_center_id       = azurerm_dev_center.devcenter.id
    resource_group_name = azurerm_resource_group.devcenter_rg.name
    location            = azurerm_resource_group.devcenter_rg.location
}

resource "azurerm_dev_center_pool" "devcenter_pool" {
    name                = var.dev_center_pool_name
    project_id          = azurerm_dev_center_project.devcenter_project.id
    resource_group_name = azurerm_resource_group.devcenter_rg.name
    location            = azurerm_resource_group.devcenter_rg.location
    sku_name            = "Standard_DS1_v2"
    os_type             = "Windows"
}