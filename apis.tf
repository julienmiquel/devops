locals {
  services = [
    "sourcerepo.googleapis.com",
    "cloudbuild.googleapis.com",
    "run.googleapis.com",
    "iam.googleapis.com",
    "container.googleapis.com",
    "containeranalysis.googleapis.com",
    "containerregistry.googleapis.com",
    "containerscanning.googleapis.com",

  ]
}

resource "google_project_service" "enabled_service" {
  provider = google-beta
  project  = var.project

  for_each = toset(local.services)
  service  = each.key

  provisioner "local-exec" {
    command = "sleep 10"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "sleep 15"
  }
}