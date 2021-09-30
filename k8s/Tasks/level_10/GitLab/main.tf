terraform {
  required_version = ">= 0.14"
  backend "azurerm" {
    subscription_id      = "7c0b0559-b933-4d68-9d8c-bf39d8711da0"
    tenant_id            = "67b7de17-01a8-410a-a645-3eacd61c1111"
    resource_group_name  = "rg-ne-shareddata"
    storage_account_name = "sanetfstate"
    container_name       = "con-ne-helocicd"
    key                  = "terraform.tfstate"
  }
}

terraform {
  required_providers {
    azurerm = {
      version = "~> 2.57.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = false
      recover_soft_deleted_key_vaults = false
    }
  }
}

resource "azurerm_resource_group" "rg_ne_aks" {
  name     = "rg-ne-${lower(var.projectname)}-aks"
  location = var.location
}

resource "azurerm_resource_group" "rg_ne_network" {
  name     = "rg-ne-${lower(var.projectname)}-network"
  location = var.location
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-ne-${lower(var.projectname)}"
  location            = azurerm_resource_group.rg_ne_network.location
  resource_group_name = azurerm_resource_group.rg_ne_network.name
}

resource "azurerm_network_ddos_protection_plan" "ddos_plan" {
  name                = "ddo-ne-${lower(var.projectname)}"
  location            = azurerm_resource_group.rg_ne_network.location
  resource_group_name = azurerm_resource_group.rg_ne_network.name
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-ne-${lower(var.projectname)}"
  location            = azurerm_resource_group.rg_ne_network.location
  resource_group_name = azurerm_resource_group.rg_ne_network.name
  address_space = [
    "10.0.0.0/16",
  ]
  ddos_protection_plan {
    id     = azurerm_network_ddos_protection_plan.ddos_plan.id
    enable = true
  }
}

resource "azurerm_subnet" "subnet_aks" {
  name                 = "sub-ne-${lower(var.projectname)}"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_virtual_network.vnet.resource_group_name
  address_prefixes = [
    "10.0.3.0/24",
  ]
}

resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.subnet_aks.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_user_assigned_identity" "aks_identity" {
  resource_group_name = azurerm_resource_group.rg_ne_aks.name
  location            = var.location
  name                = "${var.projectname}-aks-uami"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-ne-${lower(var.projectname)}"
  location            = var.location
  resource_group_name = azurerm_resource_group.rg_ne_aks.name
  dns_prefix          = "${var.projectname}-aks"
  node_resource_group = "${var.projectname}-aks"
  sku_tier            = "Free"
  default_node_pool {
    name       = "default"
    node_count = "1"
    availability_zones = [
      "1",
      "2",
      "3",
    ]
    vm_size        = "Standard_E2S_v3"
    vnet_subnet_id = azurerm_subnet.subnet_aks.id
  }
  identity {
    type                      = "UserAssigned"
    user_assigned_identity_id = azurerm_user_assigned_identity.aks_identity.id
  }
  role_based_access_control {
    enabled = true
  }
}
