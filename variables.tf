// required variables
variable "name" {
  type        = string
  description = "this name will be used as prefix for all the resources in the module"
}

variable "location" {
  type        = string
  description = <<-EOT
  {
   "type": "api",
   "purpose": "autocomplete",
   "data":"api/gcp/locations",
   "description": "regions used for deployment"
}
EOT
}

variable "network" {
  type        = string
  description = <<-EOT
  {
   "type": "api",
   "purpose": "autocomplete",
   "data":"api/gcp/network",
   "description": "this is the vpc for the cluster"
}
EOT
}

variable "subnet" {
  type        = string
  description = <<-EOT
  {
   "type": "api",
   "purpose": "autocomplete",
   "data":"api/gcp/network",
   "description": "this is the subnet for the cluster"
}
EOT
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
  description = <<-EOT
  {
   "type": "json",
   "purpose": "autocomplete",
   "data": [
    "f2-micro",
    "e3-micro",
    "e2-small",
    "g1-small",
    "e2-medium",
    "t2d-standard-1"
   ],
   "description": "regions used for deployment"
}
EOT
}

variable "project_id" {
  type        = string
  description =  <<-EOT
  {
   "type": "api",
   "purpose": "autocomplete",
   "data":"api/gcp/projectId",
   "description": "project ID"
  }
EOT
}

variable  "preemptible" {
  type        = bool
  description = <<-EOT
  {
   "type": "json",
   "purpose": "autocomplete",
   "data": [
  "true",
  "false"
   ],
   "description": "if set to true, the secondary node pool will be preemptible nodes"
}
EOT
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
  description = <<-EOT
  {
   "type": "json",
   "purpose": "autocomplete",
   "data": [
  "true",
  "false"
   ],
   "description": "if enabled cluster becomes a private cluster"
}
EOT
  default     = true
}


variable "is_shared_vpc" {
  type        = bool
  description =<<-EOT
  {
   "type": "json",
   "purpose": "autocomplete",
   "data": [
  "true",
  "false"
   ],
   "description": "if the vpc and subnet is from a shared vpc"
   }
EOT 
  default     = false
}

variable "host_project_id" {
  type        = string
  description = "the host project id, needed only if is_shared_vpc is set to true"
  default     = ""
}

variable "services_secondary_range_name" {
  type        = string
  description = "the secondary range name of the subnet to be used for services, this is needed if is_shared_vpc is enabled"
  default     = ""
}

variable "cluster_secondary_range_name" {
  type        = string
  description = "the secondary range name of the subnet to be used for pods, this is needed if is_shared_vpc is enabled"
  default     = ""
}

variable "subnet_region" {
  type        = string
  description =  <<-EOT
  {
   "type": "api",
   "purpose": "autocomplete",
   "data":"api/gcp/regions",
   "description": "regions used for deployment"
}
EOT
  default = ""
}