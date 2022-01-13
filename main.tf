resource "google_service_account" "default" {
  account_id   = "${var.name}-sa"
  display_name = "${var.name}-sa"
  project      = var.project_id
}

resource "google_container_cluster" "primary" {
  project = var.project_id
  name = "${var.name}-${var.cluster_postfix}"
  location = var.location
  networking_mode = "VPC_NATIVE"
  network = var.network
  subnetwork = var.subnet

  ip_allocation_policy {
    cluster_ipv4_cidr_block = var.is_shared_vpc ? null : "/14"
    services_ipv4_cidr_block = var.is_shared_vpc ? null : "/16"
    cluster_secondary_range_name = var.is_shared_vpc ? var.cluster_secondary_range_name : null
    services_secondary_range_name = var.is_shared_vpc ? var.services_secondary_range_name : null
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  dynamic "master_authorized_networks_config" {
    for_each = var.enable_private_cluster == true ? [1] : []
    content {
    }
  }
  
  private_cluster_config {
    enable_private_nodes    = var.enable_private_cluster
    enable_private_endpoint = var.enable_private_cluster
    master_ipv4_cidr_block  = var.enable_private_cluster ? var.master_ipv4_cidr_block : null
  }

  depends_on = [
    google_project_iam_binding.project,
    google_compute_subnetwork_iam_member.cloudservices,
    google_compute_subnetwork_iam_member.container_engine_robot,
  ]
}

resource "google_container_node_pool" "primary_node_pool" {
  project = var.project_id
  name       = "${var.name}-primary-node-pool"
  location   = var.location
  cluster    = google_container_cluster.primary.name
  initial_node_count = 1

  autoscaling {
    min_node_count = var.default_node_pool_min_count
    max_node_count = var.default_node_pool_max_count
  }

  node_config {
    service_account = google_service_account.default.email
    machine_type = var.machine_type

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
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
  initial_node_count = 1

  autoscaling {
    min_node_count = var.secondary_node_pool_min_count
    max_node_count = var.secondary_node_pool_max_count
  }

  node_config {
    service_account = google_service_account.default.email
    preemptible  = var.preemptible
    machine_type = var.machine_type

    dynamic "taint" {
      for_each = var.preemptible ? [ 
        {
          key = "cloud.google.com/gke-preemptible"
          value = "true"
          effect = "NO_SCHEDULE"
        } 
      ] : []
      
      content {
        key = taint.value.key
        value = taint.value.value
        effect = taint.value.effect
      }
    }

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    oauth_scopes    = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

// Create an external NAT IP
resource "google_compute_address" "nat" {
  count = "${var.enable_private_cluster ? 1 : 0}"
  name    = format("%s-nat-ip", var.name)
  project = var.host_project_id
  region = var.subnet_region
}

// Create a cloud router for use by the Cloud NAT
resource "google_compute_router" "router" {
  count = "${var.enable_private_cluster ? 1 : 0}"
  name    = format("%s-cloud-router", var.name)
  project = var.host_project_id
  network = var.network
  region = var.subnet_region

  bgp {
    asn = 64514
  }
}

// Create a NAT router so the nodes can reach DockerHub, etc
resource "google_compute_router_nat" "nat" {
  count = "${var.enable_private_cluster ? 1 : 0}"
  name    = format("%s-cloud-nat", var.name)
  project = var.host_project_id
  router  = google_compute_router.router[0].name
  region = google_compute_router.router.region

  nat_ip_allocate_option = "MANUAL_ONLY"

  nat_ips = [google_compute_address.nat[0].self_link]

  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = var.subnet
    source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE", "LIST_OF_SECONDARY_IP_RANGES"]

    secondary_ip_range_names = [
      var.cluster_secondary_range_name,
      var.services_secondary_range_name,
    ]
  }
}
