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
   "data":["asia-east1",
        "asia-east2",
        "asia-northeast1",
        "asia-northeast2",
        "asia-northeast3",
        "asia-south1",
        "asia-south2",
        "asia-southeast1",
        "asia-southeast2",
        "australia-southeast1",
        "australia-southeast2",
        "europe-central2",
        "europe-north1",
        "europe-west1",
        "europe-west2",
        "europe-west3",
        "europe-west4",
        "europe-west6",
        "northamerica-northeast1",
        "northamerica-northeast2",
        "southamerica-east1",
        "southamerica-west1",
        "us-central1",
        "us-east1",
        "us-east4",
        "us-west1",
        "us-west2",
        "us-west3",
        "us-west4",
        "us-east1-b",
        "us-east1-c",
        "us-east1-d",
        "us-east4-c",
        "us-east4-b",
        "us-east4-a",
        "us-central1-c",
        "us-central1-a",
        "us-central1-f",
        "us-central1-b",
        "us-west1-b",
        "us-west1-c",
        "us-west1-a",
        "europe-west4-a",
        "europe-west4-b",
        "europe-west4-c",
        "europe-west1-b",
        "europe-west1-d",
        "europe-west1-c",
        "europe-west3-c",
        "europe-west3-a",
        "europe-west3-b",
        "europe-west2-c",
        "europe-west2-b",
        "europe-west2-a",
        "asia-east1-b",
        "asia-east1-a",
        "asia-east1-c",
        "asia-southeast1-b",
        "asia-southeast1-a",
        "asia-southeast1-c",
        "asia-northeast1-b",
        "asia-northeast1-c",
        "asia-northeast1-a",
        "asia-south1-c",
        "asia-south1-b",
        "asia-south1-a",
        "australia-southeast1-b",
        "australia-southeast1-c",
        "australia-southeast1-a",
        "southamerica-east1-b",
        "southamerica-east1-c",
        "southamerica-east1-a",
        "asia-east2-a",
        "asia-east2-b",
        "asia-east2-c",
        "asia-northeast2-a",
        "asia-northeast2-b",
        "asia-northeast2-c",
        "asia-northeast3-a",
        "asia-northeast3-b",
        "asia-northeast3-c",
        "asia-south2-a",
        "asia-south2-b",
        "asia-south2-c",
        "asia-southeast2-a",
        "asia-southeast2-b",
        "asia-southeast2-c",
        "australia-southeast2-a",
        "australia-southeast2-b",
        "australia-southeast2-c",
        "europe-central2-a",
        "europe-central2-b",
        "europe-central2-c",
        "europe-north1-a",
        "europe-north1-b",
        "europe-north1-c",
        "europe-west6-a",
        "europe-west6-b",
        "europe-west6-c",
        "northamerica-northeast1-a",
        "northamerica-northeast1-b",
        "northamerica-northeast1-c",
        "northamerica-northeast2-a",
        "northamerica-northeast2-b",
        "northamerica-northeast2-c",
        "southamerica-west1-a",
        "southamerica-west1-b",
        "southamerica-west1-c",
        "us-west2-a",
        "us-west2-b",
        "us-west2-c",
        "us-west3-a",
        "us-west3-b",
        "us-west3-c",
        "us-west4-a",
        "us-west4-b",
        "us-west4-c"
    ],
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
  description = "list of avaliable machine types "
}

variable "project_id" {
  type        = string
  description = "project ID"
}

variable  "preemptible" {
  type        = bool
  description = <<-EOT
  {
   "type": "bool",
   "purpose": "autocomplete",
   "data": [
  "true",
  "false"
   ],
   "default":true
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
   "type": "bool",
   "purpose": "autocomplete",
   "data": [
  "true",
  "false"
   ],
   Default:"true",
   "description": "if enabled cluster becomes a private cluster"
}
EOT
  default     = true
}


variable "is_shared_vpc" {
  type        = bool
  description =<<-EOT
  {
   "type": "bool",
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
   "data":[ "asia-east1",
        "asia-east2",
        "asia-northeast1",
        "asia-northeast2",
        "asia-northeast3",
        "asia-south1",
        "asia-south2",
        "asia-southeast1",
        "asia-southeast2",
        "australia-southeast1",
        "australia-southeast2",
        "europe-central2",
        "europe-north1",
        "europe-west1",
        "europe-west2",
        "europe-west3",
        "europe-west4",
        "europe-west6",
        "northamerica-northeast1",
        "northamerica-northeast2",
        "southamerica-east1",
        "southamerica-west1",
        "us-central1",
        "us-east1",
        "us-east4",
        "us-west1",
        "us-west2",
        "us-west3",
        "us-west4"
    ],
   "description": "regions used for deployment"
}
EOT
  default = ""
}