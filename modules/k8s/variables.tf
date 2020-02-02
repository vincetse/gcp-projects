variable "name" {
  type        = string
  description = "Name of cluster"
}

variable "location" {
  type        = string
  description = "Cluster region or zone"
}

variable "project_id" {
  type        = string
  description = "Project ID"
}

variable "cluster_type" {
  type        = string
  description = "regional or zonal cluster"
}

variable "k8s_version" {
  type        = string
  description = "Kubernetes version"
}

variable "remove_default_node_pool" {
  type        = bool
  description = "Delete the default node pool after the cluster is created"
  default     = false
}

variable "default_node_pool" {
  type = object({
    machine_type = string
    disk_type    = string
    disk_size_gb = number
    preemptible  = bool
    count        = number
  })
  description = "Nodes in the default node pool"
  default = {
      machine_type = "f1-micro"
      disk_type    = "pd-standard"
      disk_size_gb = 20
      preemptible  = false
      count        = 3
  }
}

variable "node_pools" {
  type = list(object({
    name         = string
    machine_type = string
    disk_type    = string
    disk_size_gb = number
    preemptible  = bool
    count        = number
  }))
  description = "Type of nodes and number for each"
  default = []
}
