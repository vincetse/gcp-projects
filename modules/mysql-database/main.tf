resource "random_id" "db_instance_suffix" {
  byte_length = 2
}

locals {
  instance_name = "${var.database_name}-${random_id.db_instance_suffix.dec}"
}

resource "google_sql_database_instance" "instance" {
  name             = local.instance_name
  database_version = var.database_version
  region           = var.region
  project          = var.project_id
  settings {
    tier              = var.tier
    disk_type         = "PD_HDD"
    availability_type = var.enable_ha ? "REGIONAL" : "ZONAL"
    ip_configuration {
      ipv4_enabled    = true
      private_network = null
      require_ssl     = true # "ssl" here refers to client-side X509 certs
      dynamic "authorized_networks" {
        for_each = var.authorized_networks
        content {
          expiration_time = lookup(authorized_networks.value, "expiration_time", null)
          name            = lookup(authorized_networks.value, "name", null)
          value           = lookup(authorized_networks.value, "value", null)
        }
      }
    }
    maintenance_window {
      day          = 7 # Sunday
      hour         = 4
      update_track = "stable"
    }
    backup_configuration {
      enabled            = true
      binary_log_enabled = true
      start_time         = "05:00"
    }
  }
}

resource "google_sql_database" "db" {
  name      = var.database_name
  instance  = google_sql_database_instance.instance.name
  charset   = "utf8"
  collation = ""
  project   = var.project_id

  depends_on = [
    google_sql_database_instance.instance
  ]
}

resource "google_sql_user" "readwrite_users" {
  count = length(var.readwrite_users)

  instance = google_sql_database_instance.instance.name
  name     = var.readwrite_users[count.index]
  host     = "%"
  password = "changeme"
  project  = var.project_id
}

resource "google_sql_user" "readonly_users" {
  count = length(var.readonly_users)

  instance = google_sql_database_instance.instance.name
  name     = var.readonly_users[count.index]
  host     = "%"
  password = "changeme"
  project  = var.project_id
}
