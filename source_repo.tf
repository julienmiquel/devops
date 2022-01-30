
resource "google_service_account" "test_account" {
  provider = google-beta
  project = var.project    
  account_id   = "test-build-account"
  display_name = "Test/build Service Account"
}

resource "google_pubsub_topic" "topic" {
  provider = google-beta
  project = var.project    
  name     = "topic-repository-hackathon-cagip"
}



resource "google_sourcerepo_repository" "sources-repo" {
  depends_on = [
    google_project_service.enabled_service["sourcerepo.googleapis.com"]
  ]
  provider = google-beta
  project = var.project  
  name = "sources-repository-hackathon-cagip"
  pubsub_configs {
      topic = google_pubsub_topic.topic.id
      message_format = "JSON"
      service_account_email = google_service_account.test_account.email
  }
}

locals {
  image = "gcr.io/${var.project}/${var.namespace}"
}