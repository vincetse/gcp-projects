provider "google-beta" {
  region = "us-central1"
  zone   = "us-central1-c"
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
  url = "http://ipv4.icanhazip.com"
}

################################################################################
# authorized IP CIDRs
locals {
  project_id = "service1-32174"
  authorized_networks = [
    {
      name = "home"
      value = "${chomp(data.http.myip.body)}/32"
    },
  ]
}


################################################################################
# Common infrastructure
module "db1" {
  source           = "./modules/mysql-database"
  database_name    = "db1"
  database_version = "MYSQL_5_7"
  region           = "us-central1"
  project_id       = local.project_id
  tier             = "db-f1-micro"
  readwrite_users = [
    "vincetse",
    "foobar",
  ]
  authorized_networks = local.authorized_networks
}

output "db1_public_ip_address" {
  value = module.db1.public_ip_address
}

output "db1_private_ip_address" {
  value = module.db1.private_ip_address
}

output "mysql_cmd" {
  value =<<END

mysql -h ${module.db1.public_ip_address} -u vincetse -p db1

END
}
