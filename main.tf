//Service Account (right to call doc AI)
resource "google_service_account" "sa" {
  provider = google-beta
  project = var.project
  account_id   = var.service_account_name
  display_name = "A service account used by devops pipeline"
}

resource "google_project_iam_member" "project" {
  provider = google-beta
  project = var.project
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.sa.email}"

}

resource "google_compute_network" "default" {
  provider = google-beta  
  project                 = var.project
  name                    = "default-vpc"
  auto_create_subnetworks = true

  lifecycle { 
     ignore_changes  = all
     prevent_destroy = true 
   } 
}

resource "google_container_cluster" "demo_cluster" {
  provider = google-beta    
  project  = var.project
  name     = "cluster-demo"
  location = var.region
  network = google_compute_network.default.name

  depends_on = [
    google_project_service.container,
    google_compute_network.default,
    google_service_account.sa
  ]

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
    service_account = google_service_account.sa.email
    
    labels            = {
      env = var.env,
      tag = var.tag
    } 
  }
}

# Small Linux node pool to run some Linux-only Kubernetes Pods.
resource "google_container_node_pool" "linux_pool" {
  provider = google-beta    
  project                 = var.project
  name               = "linux-pool"
  cluster            = google_container_cluster.demo_cluster.name
  location           = google_container_cluster.demo_cluster.location
  node_count = 1

  node_config {
    machine_type = "e2-standard-4"
    image_type   = "COS_CONTAINERD"
    disk_size_gb      = 100 
    disk_type         = "pd-ssd" 

    service_account = google_service_account.sa.email

    labels            = {
      env = var.env,
      tag = var.tag
    } 
  }


  upgrade_settings {
          max_surge       = 0
          max_unavailable = 0 
  }
}


resource "google_project_service" "container" {
  provider           = google-beta    
  project            = var.project
  service            = "container.googleapis.com"
  disable_on_destroy = false
  disable_dependent_services=false 
}