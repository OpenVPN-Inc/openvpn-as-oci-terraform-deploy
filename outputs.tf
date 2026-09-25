output "admin_url" {
  description = "URL for the OpenVPN Access Server admin web UI."
  value       = "https://${local.public_ip}:943/admin"
}

# Plain-text duplicate of admin_url. Resource Manager's Application
# Information tab pulls whichever output is 'primaryOutputButton' (admin_url)
# out of the regular Application Outputs list and shows it only as the
# Primary Action button, so this copyable-string twin is what lets the admin
# URL also appear in that list.
output "admin_url_text" {
  description = "URL for the OpenVPN Access Server admin web UI (plain text, for display alongside the other outputs)."
  value       = "https://${local.public_ip}:943/admin"
}

output "site_url" {
  description = "URL for the OpenVPN Access Server client web UI."
  value       = "https://${local.public_ip}/"
}

output "admin_user" {
  description = "OpenVPN Access Server admin username."
  value       = var.admin_user
}

output "admin_password" {
  description = "OpenVPN Access Server admin password."
  value       = nonsensitive(local.admin_password)
}

output "public_ip" {
  description = "Public IP address of the OpenVPN Access Server instance (RESERVED if use_static_public_ip is true, ephemeral otherwise)."
  value       = local.public_ip
}

output "instance_id" {
  description = "OCID of the OpenVPN Access Server instance."
  value       = oci_core_instance.this.id
}
