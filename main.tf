

//Service Account (right to call doc AI)
resource "google_service_account" "sa" {
  account_id   = var.service_account_name
  display_name = "A service account used by devops pipeline"
  project      = var.project

}

resource "google_project_iam_member" "project" {
  project = var.project
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.sa.email}"

}




resource "google_container_cluster" "demo_cluster" {
  project  = var.project
  name     = "cluster-demo"
  location = var.region

  # Enable Alias IPs to allow Windows Server networking.
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "/14"
    services_ipv4_cidr_block = "/20"
  }

  # Removes the implicit default node pool, recommended when using
  # google_container_node_pool.
  remove_default_node_pool = true
  initial_node_count = 1

  node_config {
#    service_account = google_service_account.sa.name

    labels = {
      env = var.env,
      tag = var.tag
    }
    tags = ["env", var.env]
  }
}

# Small Linux node pool to run some Linux-only Kubernetes Pods.
resource "google_container_node_pool" "linux_pool" {
  name               = "linux-pool"
  project            = google_container_cluster.demo_cluster.project
  cluster            = google_container_cluster.demo_cluster.name
  location           = google_container_cluster.demo_cluster.location
  node_count = 1

  node_config {
    machine_type = "e2-standard-4"
    image_type   = "COS_CONTAINERD"
    disk_size_gb      = 100 
    disk_type         = "pd-ssd" 
    labels            = {
      env = var.env,
      tag = var.tag
    } 
#    service_account   = google_service_account.sa.name
  }

  upgrade_settings {
          max_surge       = 3
          max_unavailable = 0 
  }
}

# # Node pool of Windows Server machines.
# resource "google_container_node_pool" "windows_pool" {
#   name               = "windows-pool"
#   project            = google_container_cluster.demo_cluster.project
#   cluster            = google_container_cluster.demo_cluster.name
#   location           = google_container_cluster.demo_cluster.location

#   node_config {
#     machine_type = "e2-standard-4"
#     image_type   = "WINDOWS_LTSC" # Or WINDOWS_SAC for new features.
#   }

#   # The Linux node pool must be created before the Windows Server node pool.
#   depends_on = [google_container_node_pool.linux_pool]
# }