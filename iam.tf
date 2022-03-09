locals {
  if_create = var.is_shared_vpc ? 1 : 0
}

data "google_project" "host_project" {
  count      = local.if_create
  project_id = var.host_project_id
}

data "google_project" "service_project" {
  count      = local.if_create
  project_id = var.project_id
}

// project level access
// https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-shared-vpc
resource "google_project_iam_binding" "project" {
  count   = local.if_create
  project = data.google_project.host_project[0].project_id
  role    = "roles/container.hostServiceAgentUser"

  members = [
    "serviceAccount:service-${data.google_project.service_project[0].number}@container-engine-robot.iam.gserviceaccount.com",
  ]
}

resource "google_project_iam_binding" "securityadmin" {
  count   = local.if_create
  project = data.google_project.host_project[0].project_id
  role    = "roles/compute.securityAdmin"

  members = [
    "serviceAccount:service-${data.google_project.service_project[0].number}@container-engine-robot.iam.gserviceaccount.com",
  ]
}

// network access
// https://cloud.google.com/kubernetes-engine/docs/how-to/cluster-shared-vpc
resource "google_compute_subnetwork_iam_member" "cloudservices" {
  count      = local.if_create
  project    = data.google_project.host_project[0].project_id
  subnetwork = var.subnet
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:${data.google_project.service_project[0].number}@cloudservices.gserviceaccount.com"
}

resource "google_compute_subnetwork_iam_member" "container_engine_robot" {
  count      = local.if_create
  project    = data.google_project.host_project[0].project_id
  subnetwork = var.subnet
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:service-${data.google_project.service_project[0].number}@container-engine-robot.iam.gserviceaccount.com"
}

//Docker pull from cluster
resource "google_storage_bucket_iam_member" "member" {
  bucket = "artifacts.${var.project_id}.appspot.com"
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.default.email}"
}