output "public_ip_address" {
  value       = module.db.public_ip_address
  description = "IP address of database instance"
}

output "private_ip_address" {
  value       = module.db.private_ip_address
  description = "IP address of database instance"
}
