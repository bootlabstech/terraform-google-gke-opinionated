locals {
  if_create = var.is_shared_vpc ? 1 : 0
}

data "google_project" "host_project" {
  count = local.if_create
  project_id = var.host_project_id
}

data "google_project" "service_project" {
  count = local.if_create
  project_id = var.project_id
}

resource "google_project_iam_binding" "project" {
  count = local.if_create
  project = data.google_project.host_project[0].project_id
  role    = "roles/container.hostServiceAgentUser"

  members = [
    "serviceAccount:service-${data.google_project.service_project[0].number}@container-engine-robot.iam.gserviceaccount.com",
  ]
}