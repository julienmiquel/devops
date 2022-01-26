variable "region" {
  default = "europe-west1"
}


variable "project" {  
    default = "cloud-ops-sandbox-2234836724"
}

variable "location" {
  default = "EU"
}

variable "env" {
  default = "dev"
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

variable "gcs_tf_state" {
  default = "tf_state_devops_hackathon"
  #format("tf_state_%s", var.project)
  
}

provider "google" {
  region = var.region
}

