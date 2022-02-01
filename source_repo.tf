
resource "google_sourcerepo_repository" "sources-repo" {

  provider = google-beta
  project = var.project  
  name = "sources-repository-hackathon"

}

locals {
  image = "gcr.io/${var.project}/${var.namespace}"
}