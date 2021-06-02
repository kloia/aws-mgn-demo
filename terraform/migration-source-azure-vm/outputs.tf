

output "public_ip_dns_name" {
  description = "fqdn to connect to the first vm provisioned."
  value       = azurerm_public_ip.workload_migration_demo_public_ip.*.fqdn
}
