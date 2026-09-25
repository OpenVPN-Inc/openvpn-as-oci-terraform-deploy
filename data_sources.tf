data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# Ubuntu path only. On the marketplace path the image OCID is hard-coded via
# var.mp_listing_resource_id, as Oracle's Marketplace guidelines require (all
# binaries must be baked into the published image, not selected at apply time).
data "oci_core_images" "ubuntu" {
  count                    = var.deployment_mode == "ubuntu" ? 1 : 0
  compartment_id           = var.compartment_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04 Minimal"
  # Not filtering by 'shape' here: OCI's shape-filtered image listing only
  # returns Oracle's "recommended" catalog entries, which excludes the
  # Minimal variant even on shapes it is compatible with (verified via
  # oci compute image-shape-compatibility-entry list). Compatibility is
  # still enforced by OCI at instance launch time.
  sort_by    = "TIMECREATED"
  sort_order = "DESC"

  # The base query above still returns both x86_64 and aarch64 builds;
  # keep only the x86_64 Minimal image (no "-aarch64-" in the name).
  filter {
    name   = "display_name"
    values = ["^Canonical-Ubuntu-24\\.04-Minimal-\\d{4}\\.\\d{2}\\.\\d{2}-\\d+$"]
    regex  = true
  }
}

# Reuse-path lookups: only evaluated when create_vcn = false.
data "oci_core_vcn" "existing" {
  count  = var.create_vcn ? 0 : 1
  vcn_id = var.existing_vcn_id
}

data "oci_core_subnet" "existing" {
  count     = var.create_vcn ? 0 : 1
  subnet_id = var.existing_subnet_id
}
