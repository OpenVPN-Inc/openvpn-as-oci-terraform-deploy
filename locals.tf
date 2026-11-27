locals {
  vcn_id    = var.create_vcn ? oci_core_vcn.this[0].id : data.oci_core_vcn.existing[0].id
  subnet_id = var.create_vcn ? oci_core_subnet.this[0].id : data.oci_core_subnet.existing[0].id

  availability_domain = var.availability_domain != "" ? var.availability_domain : data.oci_identity_availability_domains.ads.availability_domains[0].name

  admin_password = var.admin_password != "" ? var.admin_password : random_password.admin.result

  ssh_public_key = var.ssh_authorized_key != "" ? var.ssh_authorized_key : tls_private_key.ssh[0].public_key_openssh

  public_ip = var.use_static_public_ip ? oci_core_public_ip.this[0].ip_address : data.oci_core_vnic.this[0].public_ip_address

  compute_image_id = var.deployment_mode == "ubuntu" ? data.oci_core_images.ubuntu[0].images[0].id : var.mp_listing_resource_id

  # One cloud-init script per deployment_mode, so the Marketplace artifact
  # carries no installer code. The name is limited to two values by the
  # validation on var.deployment_mode.
  cloud_config_file = "cloud-config-${var.deployment_mode}.yaml"

  mp_listing_resource_version = "AS_${var.as_version}"

  # A number rather than a bool so count can consume it directly.
  mp_subscription_enabled = var.deployment_mode == "marketplace" && var.mp_subscription_enabled ? 1 : 0
}
