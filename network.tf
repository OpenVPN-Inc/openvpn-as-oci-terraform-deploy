# ---- create-path resources: only created when create_vcn = true ----

resource "oci_core_vcn" "this" {
  count          = var.create_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  cidr_block     = var.vcn_cidr
  display_name   = "${var.prefix}-vcn"
}

resource "oci_core_internet_gateway" "this" {
  count          = var.create_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${var.prefix}-igw"
  enabled        = true
}

resource "oci_core_route_table" "this" {
  count          = var.create_vcn ? 1 : 0
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.this[0].id
  display_name   = "${var.prefix}-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.this[0].id
  }
}

resource "oci_core_subnet" "this" {
  count                      = var.create_vcn ? 1 : 0
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.this[0].id
  cidr_block                 = var.subnet_cidr
  display_name               = "${var.prefix}-subnet"
  route_table_id             = oci_core_route_table.this[0].id
  prohibit_public_ip_on_vnic = false
  # No availability_domain set: this is a regional subnet.
}

# ---- security: network security group, one rule resource per port ----

resource "oci_core_network_security_group" "this" {
  compartment_id = var.compartment_ocid
  vcn_id         = local.vcn_id
  display_name   = "${var.prefix}-nsg"
}

resource "oci_core_network_security_group_security_rule" "tcp_22" {
  count                     = var.enable_tcp_22 ? 1 : 0
  network_security_group_id = oci_core_network_security_group.this.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.tcp_22_source_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "tcp_443" {
  count                     = var.enable_tcp_443 ? 1 : 0
  network_security_group_id = oci_core_network_security_group.this.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.tcp_443_source_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "tcp_943" {
  count                     = var.enable_tcp_943 ? 1 : 0
  network_security_group_id = oci_core_network_security_group.this.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = var.tcp_943_source_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = false

  tcp_options {
    destination_port_range {
      min = 943
      max = 943
    }
  }
}

resource "oci_core_network_security_group_security_rule" "udp_1194" {
  count                     = var.enable_udp_1194 ? 1 : 0
  network_security_group_id = oci_core_network_security_group.this.id
  direction                 = "INGRESS"
  protocol                  = "17"
  source                    = var.udp_1194_source_cidr
  source_type               = "CIDR_BLOCK"
  stateless                 = false

  udp_options {
    destination_port_range {
      min = 1194
      max = 1194
    }
  }
}

resource "oci_core_network_security_group_security_rule" "egress_all" {
  network_security_group_id = oci_core_network_security_group.this.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  destination_type          = "CIDR_BLOCK"
  stateless                 = false
}
