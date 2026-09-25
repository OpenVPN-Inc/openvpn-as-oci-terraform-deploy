resource "random_password" "admin" {
  length           = 12
  override_special = "!@#$%^&*()-_=+"
}

resource "oci_core_instance" "this" {
  compartment_id      = var.compartment_ocid
  availability_domain = local.availability_domain
  display_name        = "${var.prefix}-instance"
  shape               = var.shape

  shape_config {
    ocpus         = var.flex_ocpus
    memory_in_gbs = var.flex_memory_in_gbs
  }

  create_vnic_details {
    subnet_id        = local.subnet_id
    assign_public_ip = var.use_static_public_ip ? false : true
    nsg_ids          = [oci_core_network_security_group.this.id]
    display_name     = "${var.prefix}-vnic"
  }

  source_details {
    source_type             = "image"
    source_id               = local.compute_image_id
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  metadata = {
    ssh_authorized_keys = var.ssh_authorized_key
    user_data = base64encode(templatefile("${path.module}/scripts/cloud-config.yaml", {
      admin_user         = var.admin_user
      admin_password     = local.admin_password
      enable_letsencrypt = var.enable_letsencrypt
      as_version         = var.as_version
    }))
  }

  # The Marketplace listing agreement/subscription must be accepted before an
  # instance can be launched from the listing's image. On the ubuntu path those
  # resources have count = 0, which makes this dependency a harmless no-op.
  depends_on = [oci_core_app_catalog_subscription.mp_image_subscription]

  timeouts {
    create = "60m"
  }
}

# The instance's primary VNIC gets an ephemeral private IP; look it up so a
# stable RESERVED public IP can be attached to it when use_static_public_ip
# is true (Let's Encrypt needs a public address that survives instance
# stop/start; a plain OCI ephemeral public IP does not).
data "oci_core_vnic_attachments" "this" {
  compartment_id = var.compartment_ocid
  instance_id    = oci_core_instance.this.id
}

data "oci_core_private_ips" "this" {
  count   = var.use_static_public_ip ? 1 : 0
  vnic_id = data.oci_core_vnic_attachments.this.vnic_attachments[0].vnic_id
}

resource "oci_core_public_ip" "this" {
  count          = var.use_static_public_ip ? 1 : 0
  compartment_id = var.compartment_ocid
  display_name   = "${var.prefix}-public-ip"
  lifetime       = "RESERVED"
  private_ip_id  = data.oci_core_private_ips.this[0].private_ips[0].id
}

# use_static_public_ip = false: the VNIC was created with assign_public_ip =
# true, so OCI already assigned it an ephemeral public IP at launch. Read the
# VNIC back to expose that address the same way the RESERVED IP is exposed.
data "oci_core_vnic" "this" {
  count   = var.use_static_public_ip ? 0 : 1
  vnic_id = data.oci_core_vnic_attachments.this.vnic_attachments[0].vnic_id
}
