variable "projectname" {
  default = "HelloCiCd"
}
variable "location" {
  default = "northeurope"
}

variable "aks_node_count" {
  default = "1"
}

variable "acr_sku" {
  default = "Basic"
}

locals {
  default_tags = {
    Administrator = "Cmajdalka"
    Application   = var.projectname
    ManagedBy     = "terraform"
  }
}
variable "aks_application_list" {
  default = "Hello CI/CD & Neaxt app"
}
