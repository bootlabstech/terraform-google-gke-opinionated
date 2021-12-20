// required variables
variable "name" {
  type        = string
  description = "this name will be used as prefix for all the resources in the module"
}

variable "location" {
  type        = string
  description = "this is the location where all the resources will be created"
}

variable "network" {
  type        = string
  description = "this is the vpc for the cluster"
}

variable "subnet" {
  type        = string
  description = "this is the subnet for the cluster"
}

variable "default_node_pool_min_count" {
  type        = number
  description = "this is the min count in the default node pool"
}

variable "default_node_pool_max_count" {
  type        = number
  description = "this is the max count in the default node pool"
}

variable "secondary_node_pool_min_count" {
  type        = number
  description = "this is the min count in the secondary node pool"
}

variable "secondary_node_pool_max_count" {
  type        = number
  description = "this is the min count in the secondary node pool"
}

variable "machine_type" {
  type        = string
  description = "this is the machine type for primary and secondary node pool"
}

variable "project_id" {
  type        = string
  description = "this is the project id in which the cluster is created"
}

variable  "preemptible" {
  type        = bool
  description = "if set to true, the secondary node pool will be preemptible nodes"
}

// optional variables
variable "service_account_id" {
  type        = string
  description = "the id is used as a postfix in service account created for the kubernetes engine"
  default     = "gke-sa"
}

variable "cluster_postfix" {
  type        = string
  description = "this will be used as the postfix for the cluster name, along with var.name"
  default     = "gke-k8s"
}

variable "master_ipv4_cidr_block" {
  type        = string
  description = "the master network ip range"
  default     = "172.16.0.32/28"
}

variable "enable_private_cluster" {
  type        = bool
  description = "if enabled cluster becomes a private cluster"
  default     = true
}

variable "is_shared_vpc" {
  type        = bool
  description = "if the vpc and subnet is from a shared vpc"
  default     = false
}

variable "host_project_id" {
  type        = string
  description = "the host project id, needed only if is_shared_vpc is set to true"
  default     = ""
}