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


variable "tag" {
  default = "devops_hackathon"
}

variable "deletion_protection" {
  default = false
}

variable "gcs_tf_state" {
  default = "tf_state_devops_hackathon"  
}

provider "google" {
  region = var.region
}
