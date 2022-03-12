resource "google_service_account" "default" {
  account_id   = "${var.name}-sa"
  display_name = "${var.name}-sa"
  project      = var.project_id
}

resource "google_container_cluster" "primary" {
  project                     = var.project_id
  name                        = "${var.name}-${var.cluster_postfix}"
  location                    = var.location
  node_locations              = length(var.node_locations) != 0 ? var.node_locations : null
  networking_mode             = "VPC_NATIVE"
  network                     = var.network
  subnetwork                  = var.subnet
  enable_shielded_nodes       = var.enable_shielded_nodes
  enable_intranode_visibility = var.enable_intranode_visibility
  #enable_binary_authorization = var.enable_binary_authorization

  ip_allocation_policy {
    cluster_ipv4_cidr_block       = var.is_shared_vpc ? null : "/14"
    services_ipv4_cidr_block      = var.is_shared_vpc ? null : "/16"
    cluster_secondary_range_name  = var.is_shared_vpc ? var.cluster_secondary_range_name : null
    services_secondary_range_name = var.is_shared_vpc ? var.services_secondary_range_name : null
  }

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = var.remove_default_node_pool
  initial_node_count       = 1

  dynamic "master_authorized_networks_config" {
    for_each = var.enable_private_cluster == true ? [1] : []
    content {
    }
  }

  dynamic "workload_identity_config" {
    for_each = var.workload_identity ? [1] : []
    content {
      workload_pool = "${var.project_id}.svc.id.goog"
    }
  }

  private_cluster_config {
    enable_private_nodes    = var.enable_private_cluster
    enable_private_endpoint = var.enable_private_cluster
    master_ipv4_cidr_block  = var.enable_private_cluster ? var.master_ipv4_cidr_block : null
  }

  //this is needed even if we are deleting defaul node pool at once
  //because if we are enabling shielded nodes we have to enable secure boot also, without which default node pool 
  //won't be created
  dynamic "node_config" {
    for_each = var.enable_shielded_nodes ? [1] : []
    content {
      service_account   = google_service_account.default.email
      machine_type      = var.machine_type
      image_type        = var.image_type

      # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
      oauth_scopes = tolist(var.oauth_scopes)
      dynamic "workload_metadata_config" {
        for_each = var.workload_identity ? [1] : []
        content {
          mode = "GKE_METADATA"
        }
      }
      shielded_instance_config {
        enable_secure_boot          = true
        enable_integrity_monitoring = true
      }
    }
  }

  depends_on = [
    google_project_iam_binding.project,
    google_compute_subnetwork_iam_member.cloudservices,
    google_compute_subnetwork_iam_member.container_engine_robot,
  ]
}

resource "google_container_node_pool" "primary_node_pool" {
  provider           = google-beta
  project            = var.project_id
  name               = "${var.name}-primary-node-pool"
  location           = var.location
  cluster            = google_container_cluster.primary.name
  initial_node_count = 1

  autoscaling {
    min_node_count = var.default_node_pool_min_count
    max_node_count = var.default_node_pool_max_count
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    service_account   = google_service_account.default.email
    machine_type      = var.machine_type
    image_type        = var.image_type
    boot_disk_kms_key = var.boot_disk_kms_key

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    oauth_scopes = tolist(var.oauth_scopes)
    dynamic "workload_metadata_config" {
      for_each = var.workload_identity ? [1] : []
      content {
        mode = "GKE_METADATA"
      }
    }
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }
}

resource "google_container_node_pool" "secondary_node_pool" {
  provider           = google-beta
  project            = var.project_id
  name               = "${var.name}-secondary-node-pool"
  location           = var.location
  cluster            = google_container_cluster.primary.name
  initial_node_count = 1

  autoscaling {
    min_node_count = var.secondary_node_pool_min_count
    max_node_count = var.secondary_node_pool_max_count
  }

  management {
    auto_repair = true
    auto_upgrade = true
  }

  node_config {
    service_account   = google_service_account.default.email
    preemptible       = var.preemptible
    machine_type      = var.machine_type
    image_type        = var.image_type
    boot_disk_kms_key = var.boot_disk_kms_key == "" ? null : var.boot_disk_kms_key

    dynamic "taint" {
      for_each = var.preemptible ? [
        {
          key    = "cloud.google.com/gke-preemptible"
          value  = "true"
          effect = "NO_SCHEDULE"
        }
      ] : []

      content {
        key    = taint.value.key
        value  = taint.value.value
        effect = taint.value.effect
      }
    }

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    oauth_scopes = tolist(var.oauth_scopes)
    dynamic "workload_metadata_config" {
      for_each = var.workload_identity ? [1] : []
      content {
        mode = "GKE_METADATA"
      }
    }
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }
  }
}

//Enable a route to default internet gateway
//Enable this if private google access is being used, check compatibility with automatically created dns zone in host project
//Don't use this if cloud NAT is enabled
resource "google_compute_route" "route" {
  count            = var.enable_private_cluster && var.enable_private_googleapis_route ? 1 : 0
  name             = "private-googleapis-route"
  project          = var.host_project_id
  dest_range       = "199.36.153.8/30"
  network          = var.network
  next_hop_gateway = "default-internet-gateway"
  priority         = 0
}

//Create an external NAT IP
//Don't use this if private google access is being used
resource "google_compute_address" "nat" {
  count   = var.enable_private_cluster && var.enable_cloud_nat ? 1 : 0
  name    = format("%s-nat-ip", var.name)
  project = var.host_project_id
  region  = var.subnet_region
}

//Create a cloud router for use by the Cloud NAT
//Don't use this if private google access is being used
resource "google_compute_router" "router" {
  count   = var.enable_private_cluster && var.enable_cloud_nat ? 1 : 0
  name    = format("%s-cloud-router", var.name)
  project = var.host_project_id
  network = var.network
  region  = var.subnet_region

  bgp {
    asn = 64514
  }
}

//Create a NAT router so the nodes can reach DockerHub, etc
//Don't use this if private google access is being used
resource "google_compute_router_nat" "nat" {
  count   = var.enable_private_cluster && var.enable_cloud_nat ? 1 : 0
  name    = format("%s-cloud-nat", var.name)
  project = var.host_project_id
  router  = google_compute_router.router[0].name
  region  = google_compute_router.router[0].region

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