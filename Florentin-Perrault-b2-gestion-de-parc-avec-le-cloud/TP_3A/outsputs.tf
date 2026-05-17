output "vm_public_ip" {
  description = "adresse ip publique de la vm"
  value       = azurerm_public_ip.main.ip_address
}

output "vm_dns_name" {
  description = "le nom dns de la vm"
  value       = azurerm_private_dns_zone.dnsvortix.name
}
