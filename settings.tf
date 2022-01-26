// Storage staging
resource "google_storage_bucket" "staging" {
  name                        = format("tf_state_%s", var.project)
  location                    = var.location
  force_destroy               = true
  project                     = var.project
  uniform_bucket_level_access = true
  labels = {
    "env" : var.env
  }
}

data "terraform_remote_state" "foo" {
  backend = "gcs"
  config = {
    bucket  = var.gcs_tf_state
    prefix  = format("env_%s", var.tag)
  }
}


