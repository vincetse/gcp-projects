resource "random_id" "db_instance_suffix" {
  byte_length = 2
}

locals {
  instance_name = "${var.database_name}-${random_id.db_instance_suffix.dec}"
}

module "db" {
  source           = "GoogleCloudPlatform/sql-db/google//modules/mysql"
  version          = "3.0.0"
  name             = local.instance_name
  database_version = var.database_version
  project_id       = var.project_id
  zone             = "a"
  region           = var.region
  tier             = var.tier
  ip_configuration = {
    ipv4_enabled        = true
    private_network     = null
    require_ssl         = false # Don't require client-side X509 certs, but server-side SSL is still in force
    authorized_networks = var.authorized_networks
  }
  database_flags = [
    {
      name  = "log_bin_trust_function_creators"
      value = "on"
    },
  ]
  maintenance_window_day          = 7 # sunday
  maintenance_window_hour         = 7
  maintenance_window_update_track = "stable"
  # default dataname
  db_name = var.database_name
  #db_charset = "utf8"
  #db_collation = "latin1"
}

resource "google_sql_user" "readwrite_users" {
  count = length(var.readwrite_users)

  instance = module.db.instance_name
  name     = var.readwrite_users[count.index]
  host     = "%"
  password = "changeme"
  project  = var.project_id
}

resource "google_sql_user" "readonly_users" {
  count = length(var.readonly_users)

  instance = module.db.instance_name
  name     = var.readonly_users[count.index]
  host     = "%"
  password = "changeme"
  project  = var.project_id
}
