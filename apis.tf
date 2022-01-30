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
    "containerfilesystem.googleapis.com" ,
    "containerthreatdetection.googleapis.com",

    "anthosconfigmanagement.googleapis.com",
    "anthosgke.googleapis.com",
    "anthosidentityservice.googleapis.com",
    "computescanning.googleapis.com",
    "buildhistory.googleapis.com",
    "sourcerepo.googleapis.com",
    "servicenetworking.googleapis.com",
    "firestore.googleapis.com",
    "vpcaccess.googleapis.com",
    "pubsub.googleapis.com", 
    "bigquery.googleapis.com",
    "monitoring.googleapis.com",
    "cloudtrace.googleapis.com",
    "cloudtrace.googleapis.com"

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