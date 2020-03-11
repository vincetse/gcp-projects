provider "google-beta" {
  region = "us-central1"
  zone   = "us-central1-c"
  alias  = "google_beta"
}

provider "google" {
  region = "us-central1"
  zone   = "us-central1-c"
}

data "google_organization" "org" {
  domain = "thelazyenginerd.github.io"
}

################################################################################
data "http" "myip" {
  url = "http://ifconfig.co"
}

################################################################################
# authorized IP CIDRs
locals {
  #project_id = "service1-32174"
  project_id = "iam-tester-268900"
  authorized_networks = [
    {
      name  = "home"
      value = "${chomp(data.http.myip.body)}/32"
    },
  ]
}


################################################################################
## Common infrastructure
#module "db1" {
#  source           = "./modules/mysql-database"
#  database_name    = "db1"
#  database_version = "MYSQL_5_7"
#  region           = "us-central1"
#  project_id       = local.project_id
#  tier             = "db-f1-micro"
#  readwrite_users = [
#    "vincetse",
#    "foobar",
#  ]
#  authorized_networks = local.authorized_networks
#}
#
#output "db1_public_ip_address" {
#  value = module.db1.public_ip_address
#}
#
#output "db1_private_ip_address" {
#  value = module.db1.private_ip_address
#}
#
#output "mysql_cmd" {
#  value = <<END
#
#mysql -h ${module.db1.public_ip_address} -u vincetse -p db1
#
#END
#}


################################################################################
# Container infrastructure
locals {
  container_cluster_name = "k8s-1"
  container_cluster_zone = "us-central1-a"
  k8s_version = "1.14.10-gke.22"
  cluster_type = "zonal"
}

module "k8s" {
  source       = "github.com/infrastructure-as-code/terraform-google-gke-cluster"
  name         = local.container_cluster_name
  location     = local.container_cluster_zone
  cluster_type = local.cluster_type
  k8s_version  = local.k8s_version
  project_id   = local.project_id

  remove_default_node_pool = false
  default_node_pool = {
      machine_type = "e2-standard-2"
      disk_type    = "pd-standard"
      disk_size_gb = 100
      preemptible  = true
      count        = 3
  }

#  remove_default_node_pool = true
#  node_pools = [
#    {
#      name         = "main-pool"
#      machine_type = "e2-standard-2"
#      disk_type    = "pd-standard"
#      disk_size_gb = 100
#      preemptible  = true
#      count        = 3
#    },
#  ]

  providers = {
    google = google-beta.google_beta
  }
}

resource "null_resource" "kubeconfig" {
  provisioner "local-exec" {
    command = "gcloud beta container clusters get-credentials ${local.container_cluster_name} --zone ${local.container_cluster_zone} --project ${local.project_id}"
  }
  depends_on = [
    module.k8s
  ]
}

output "k8s_endpoint" {
  value = module.k8s.endpoint
}

output "k8s_ca_certificate" {
  value = module.k8s.ca_certificate
}

output "configure_kubectl" {
  value = module.k8s.configure_kubectl
}
