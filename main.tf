resource "google_service_account" "default" {
  account_id   = "${var.name}-${var.service_account_id}"
  display_name = "${var.name}-${var.service_account_id}"
  project = var.project_id
}

resource "google_container_cluster" "primary" {
  project = var.project_id
  name = "${var.name}-${var.cluster_postfix}"
  location = var.location
  networking_mode = "VPC_NATIVE"
  network = var.network
  subnetwork = var.subnet

  ip_allocation_policy {
    cluster_ipv4_cidr_block = "/14"
    services_ipv4_cidr_block = "/16"
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_node_pool" {
  project = var.project_id
  name       = "${var.name}-primary-node-pool"
  location   = var.location
  cluster    = google_container_cluster.primary.name
  node_count = 1

  autoscaling {
    min_node_count = var.default_node_pool_min_count
    max_node_count = var.default_node_pool_max_count
  }

  node_config {
    machine_type = var.machine_type

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

resource "google_container_node_pool" "secondary_node_pool" {
  project = var.project_id
  name       = "${var.name}-secondary-node-pool"
  location   = var.location
  cluster    = google_container_cluster.primary.name
  node_count = 1

  autoscaling {
    min_node_count = var.secondary_node_pool_min_count
    max_node_count = var.secondary_node_pool_max_count
  }

  node_config {
    machine_type = var.machine_type

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.default.email
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}