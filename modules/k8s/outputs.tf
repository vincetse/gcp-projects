output "endpoint" {
  value       = google_container_cluster.primary.endpoint
  description = "Kubernetes endpoint"
}

output "ca_certificate" {
  value       = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
  description = "Kubernetes cluster CA certificate"
}

output "configure_kubectl" {
  value       = "gcloud container clusters get-credentials ${var.name} --zone ${var.location} --project ${var.project_id}"
  description = "Command to configure credentials for kubectl"
}
