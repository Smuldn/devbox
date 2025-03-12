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

resource "azurerm_dev_center_project_pool" "devcenter_pool" {
    name                                    = var.dev_center_pool_name
    location                                = azurerm_resource_group.devcenter_rg.location
    dev_center_project_id                   = azurerm_dev_center_project.devcenter_project.id
    dev_box_definition_name                 = azurerm_dev_center_dev_box_definition.example.name
    local_administrator_enabled             = true
    dev_center_attached_network_name        = azurerm_dev_center_attached_network.example.name
    stop_on_disconnect_grace_period_minutes = 60
}