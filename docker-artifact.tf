resource "google_artifact_registry_repository" "repo-docker-hackathon"     {
  provider = google-beta
  project = var.project

  location = var.region
  repository_id = "repo-docker-hackathon"
  description = "Google cloud docker repository"
  format = "docker"
}

resource "google_service_account" "repo-account" {
  provider = google-beta
  project = var.project

  account_id   = "repo-sa-reader"
  display_name = "Repository Service Account reader"
}

resource "google_artifact_registry_repository_iam_member" "repo-iam-reader" {
  provider = google-beta
  project = var.project

  location = google_artifact_registry_repository.repo-docker-hackathon.location
  repository = google_artifact_registry_repository.repo-docker-hackathon.name
  role   = "roles/artifactregistry.reader"
  member = "serviceAccount:${google_service_account.repo-account.email}"
}

resource "google_service_account" "repo-account-writer" {
  provider = google-beta
  project = var.project

  account_id   = "repo-sa-writer"
  display_name = "Repository Service Account writer"
}

resource "google_artifact_registry_repository_iam_member" "repo-iam-writer" {
  provider = google-beta
  project = var.project

  location = google_artifact_registry_repository.repo-docker-hackathon.location
  repository = google_artifact_registry_repository.repo-docker-hackathon.name
  role   = "roles/artifactregistry.writer"
  member = "serviceAccount:${google_service_account.repo-account-writer.email}"
}

