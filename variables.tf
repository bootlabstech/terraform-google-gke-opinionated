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
   "data": "/api/v1/autocomplete/regions",
   "description": "regions used for deployment"
}
EOT
}

variable "network" {
  type        = string
  description = "this is the vpc for the cluster"

}

variable "subnet" {
  type        = string
  description =  "this is the subnet for the cluster"
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
   "data": [ "c2-standard-16",    
             "c2-standard-30",
             "c2-standard-4",
             "c2-standard-60",
             "c2-standard-8",
             "e2-highcpu-16",
             "e2-highcpu-2",
             "e2-highcpu-32",
             "e2-highcpu-4",
             "e2-highcpu-8",
             "e2-highmem-16",
             "e2-highmem-2",
             "e2-highmem-4",
             "e2-highmem-8",
             "e2-medium",
             "e2-micro",
             "e2-small",
             "e2-standard-16",
             "e2-standard-2",
             "e2-standard-32",
             "e2-standard-4",
             "e2-standard-8",
             "f1-micro",
             "g1-small",
             "m1-megamem-96",
             "m1-ultramem-160",
             "m1-ultramem-40",
             "m1-ultramem-80",
             "m2-megamem-416",
             "m2-ultramem-208",
             "m2-ultramem-416",
             "n1-highcpu-16",
             "n1-highcpu-2",
             "n1-highcpu-32",
             "n1-highcpu-4",
             "n1-highcpu-64",
             "n1-highcpu-8",
             "n1-highcpu-96",
             "n1-highmem-16",
             "n1-highmem-2",
             "n1-highmem-32",
             "n1-highmem-4",
             "n1-highmem-64",
             "n1-highmem-8",
             "n1-highmem-96",
             "n1-standard-1",
             "n1-standard-16",
             "n1-standard-2",
             "n1-standard-32",
             "n1-standard-4",
             "n1-standard-64",
             "n1-standard-8",
             "n1-standard-96",
             "n1-ultramem-160",
             "n1-ultramem-40",
             "n1-ultramem-80",
             "n2-highcpu-16",
             "n2-highcpu-2",
             "n2-highcpu-32",
             "n2-highcpu-4",
             "n2-highcpu-48",
             "n2-highcpu-64",
             "n2-highcpu-8",
             "n2-highcpu-80",
             "n2-highmem-16",
             "n2-highmem-2",
             "n2-highmem-32",
             "n2-highmem-4",
             "n2-highmem-48",
             "n2-highmem-64",
             "n2-highmem-8",
             "n2-highmem-80",
             "n2-standard-16",
             "n2-standard-2",
             "n2-standard-32",
             "n2-standard-4",
             "n2-standard-48",
             "n2-standard-64",
             "n2-standard-8",
             "n2-standard-80",
             "n2d-highcpu-128",
             "n2d-highcpu-16",
             "n2d-highcpu-2",
             "n2d-highcpu-224",
             "n2d-highcpu-32",
             "n2d-highcpu-4",
             "n2d-highcpu-48",
             "n2d-highcpu-64",
             "n2d-highcpu-8",
             "n2d-highcpu-80",
             "n2d-highcpu-96",
             "n2d-highmem-16",
             "n2d-highmem-2",
             "n2d-highmem-32",
             "n2d-highmem-4",
             "n2d-highmem-48",
             "n2d-highmem-64",
             "n2d-highmem-8",
             "n2d-highmem-80",
             "n2d-highmem-96",
             "n2d-standard-128",
             "n2d-standard-16",
             "n2d-standard-2",
             "n2d-standard-224",
             "n2d-standard-32",
             "n2d-standard-4",
             "n2d-standard-48",
             "n2d-standard-64",
             "n2d-standard-8",
             "n2d-standard-80",
             "n2d-standard-96"
            ],
   "description": "The machine type to create."
}
EOT
}

variable "project_id" {
  type        = string
  description = "project ID"
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
   "default":true,
   "description": "if set to true, the secondary node pool will be preemptible nodes"
}
EOT
}
variable "tags" {
  type        = list(string)
  description = "this will be used for tagging resources."
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
   "Default":"true",
   "description": "if enabled cluster becomes a private cluster"
}
EOT
  default     = true
}


variable "is_shared_vpc" {
  type        = bool
  description = <<-EOT
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
   "data": "/api/v1/autocomplete/regions",
   "description": "regions used for deployment"
}
EOT
  default = ""
}
