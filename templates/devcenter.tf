provider "azurerm" {
    features {}
    subscription_id = "35fa58b6-f21a-4a97-91db-c07b0b3ff601"
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

resource "azurerm_resource_group" "dev_center_rg" {
    name     = var.resource_group_name
    location = var.location
}

resource "azurerm_dev_center" "dev_center" {
    name                = var.dev_center_name
    resource_group_name = azurerm_resource_group.dev_center_rg.name
    location            = azurerm_resource_group.dev_center_rg.location

    identity {
        type = "SystemAssigned"
    }
}

resource "azurerm_virtual_network" "dev_center_vnet" {
    name                = "dev-center-vnet"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.dev_center_rg.location
    resource_group_name = azurerm_resource_group.dev_center_rg.name
}

resource "azurerm_subnet" "dev_center_subnet" {
    name                 = "internal"
    resource_group_name  = azurerm_resource_group.dev_center_rg.name
    virtual_network_name = azurerm_virtual_network.dev_center_vnet.name
    address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_dev_center_network_connection" "dev_center_network_connection" {
    name                = "dev-center-dcnc"
    resource_group_name = azurerm_resource_group.dev_center_rg.name
    location            = azurerm_resource_group.dev_center_rg.location
    subnet_id           = azurerm_subnet.dev_center_subnet.id
    domain_join_type    = "AzureADJoin"
}

resource "azurerm_dev_center_attached_network" "dev_center_attached_network" {
    name                  = "dev-center-dcet"
    dev_center_id         = azurerm_dev_center.dev_center.id
    network_connection_id = azurerm_dev_center_network_connection.dev_center_network_connection.id
}

resource "azurerm_dev_center_project" "dev_center_project" {
    name                = var.dev_center_project_name
    resource_group_name = azurerm_resource_group.dev_center_rg.name
    location            = azurerm_resource_group.dev_center_rg.location
    dev_center_id       = azurerm_dev_center.dev_center.id
}

resource "azurerm_dev_center_dev_box_definition" "dev_center_dev_box_definition" {
    name               = "dev-center-dcet"
    location           = azurerm_resource_group.dev_center_rg.location
    dev_center_id      = azurerm_dev_center.dev_center.id
    image_reference_id = "${azurerm_dev_center.dev_center.id}/galleries/default/images/microsoftvisualstudio_visualstudioplustools_vs-2022-ent-general-win10-m365-gen2"
    sku_name           = "general_i_8c32gb256ssd_v2"
}

resource "azurerm_dev_center_project_pool" "dev_center_project_pool" {
    name                                    = var.dev_center_pool_name
    location                                = azurerm_resource_group.dev_center_rg.location
    dev_center_project_id                   = azurerm_dev_center_project.dev_center_project.id
    dev_box_definition_name                 = azurerm_dev_center_dev_box_definition.dev_center_dev_box_definition.name
    local_administrator_enabled             = true
    dev_center_attached_network_name        = azurerm_dev_center_attached_network.dev_center_attached_network.name
    stop_on_disconnect_grace_period_minutes = 60
}