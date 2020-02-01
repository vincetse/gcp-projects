variable "database_name" {
  type        = string
  description = "Database name"
}

variable "database_version" {
  type        = string
  description = "Database version (MYSQL_5_6, MYSQL_5_7, POSTGRES_9_6, POSTGRES_11)"
}

variable "region" {
  type        = string
  description = "GCP region"
}

variable "project_id" {
  type        = string
  description = "Project ID"
}

variable "tier" {
  type        = string
  description = "Instance tier"
}

variable "readwrite_users" {
  type        = list(string)
  description = "list of users with read-write access"
  default     = []
}

variable "readonly_users" {
  type        = list(string)
  description = "list of users with read-only access"
  default     = []
}

variable "authorized_networks" {
  type = list(object({
    name  = string
    value = string
  }))
  description = "list of IP CIDRs that are allowed to access the database"
  default     = []
}

variable "enable_ha" {
  type = bool
  description = "Enable high availability with regional deployment"
  default = false
}
