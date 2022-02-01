
resource "google_sourcerepo_repository" "sources-repo" {

  provider = google-beta
  project = var.project  
  name = "sources-repository-hackathon"
  pubsub_configs {
      topic = google_pubsub_topic.topic.id
      message_format = "JSON"
      service_account_email = google_service_account.test_account.email
  }
}

locals {
  image = "gcr.io/${var.project}/${var.namespace}"
}