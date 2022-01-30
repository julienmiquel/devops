# This file has some scaffolding to make sure that names are unique and that
# a region and zone are selected when you try to create your Terraform resources.

locals {
  name_suffix = "${random_pet.suffix.id}"
}

resource "random_pet" "suffix" {
  length = 2
}

variable "region" {
  default = "europe-west1"
}


variable "project" {  
    default = ""
}

variable "location" {
  default = "EU"
}

variable "env" {
  default = "dev"
}

variable "namespace" {
  default = "devops_hackathon"
}


variable "tag" {
  default = "devops_hackathon"
}

variable "service_account_name" {
  default = "devops-sa-1"
}

variable "deletion_protection" {
  default = false
}


provider "google" {
  region = var.region
}

provider "google-beta" {
  region = var.region
}

