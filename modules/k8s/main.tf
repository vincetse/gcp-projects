locals {
  initial_node_count = var.cluster_type == "regional" ? 1 : 3
  node_image_type    = "cos"
  oauth_scopes = [
    # gke-default
    "https://www.googleapis.com/auth/devstorage.read_only",
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
    "https://www.googleapis.com/auth/service.management.readonly",
    "https://www.googleapis.com/auth/servicecontrol",
    "https://www.googleapis.com/auth/trace.append",
  ]
}

resource "google_container_cluster" "primary" {
  name     = var.name
  location = var.location
  project  = var.project_id

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = var.remove_default_node_pool
  initial_node_count       = var.default_node_pool.count
  min_master_version       = var.k8s_version

  master_auth {
    username = ""
    password = ""
    client_certificate_config {
      issue_client_certificate = true
    }
  }

  node_config {
    preemptible  = var.default_node_pool.preemptible
    machine_type = var.default_node_pool.machine_type
    disk_type    = var.default_node_pool.disk_type
    disk_size_gb = var.default_node_pool.disk_size_gb
    image_type   = local.node_image_type

    metadata = {
      disable-legacy-endpoints = "true"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    oauth_scopes = local.oauth_scopes
  }

  ip_allocation_policy {
    cluster_ipv4_cidr_block  = "10.3.0.0/16"
    services_ipv4_cidr_block = "10.4.0.0/20"
  }

  addons_config {
    http_load_balancing {
      disabled = false
    }
    cloudrun_config {
      disabled = false
    }
    istio_config {
      disabled = false
      auth     = "AUTH_MUTUAL_TLS"
    }
  }

  maintenance_policy {
    recurring_window {
      start_time = "2019-01-01T04:00:00Z"
      end_time   = "2019-01-01T08:00:00Z"
      recurrence = "FREQ=WEEKLY;BYDAY=MO,TU,WE,TH,FR,SA,SU"
    }
  }
}

resource "google_container_node_pool" "fleet" {
  count = length(var.node_pools)

  name       = var.node_pools[count.index].name
  location   = var.location
  project    = var.project_id
  cluster    = google_container_cluster.primary.name
  node_count = var.node_pools[count.index].count
  version    = var.k8s_version

  autoscaling {
    min_node_count = var.node_pools[count.index].count
    max_node_count = var.node_pools[count.index].count
  }

  node_config {
    preemptible  = var.node_pools[count.index].preemptible
    machine_type = var.node_pools[count.index].machine_type
    disk_type    = var.node_pools[count.index].disk_type
    disk_size_gb = var.node_pools[count.index].disk_size_gb
    image_type   = local.node_image_type

    metadata = {
      disable-legacy-endpoints = "true"
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    oauth_scopes = local.oauth_scopes
  }

  depends_on = [
    google_container_cluster.primary
  ]
}
