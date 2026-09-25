# ---- Resource Manager auto-injected variables (fixed names, do not rename) ----

variable "tenancy_ocid" {
  type        = string
  description = "OCID of the tenancy. Automatically supplied by OCI Resource Manager."
}

variable "region" {
  type        = string
  description = "OCI region identifier (e.g. us-ashburn-1). Automatically supplied by OCI Resource Manager."
}

variable "compartment_ocid" {
  type        = string
  description = "OCID of the compartment in which to create all resources. Automatically supplied by OCI Resource Manager."
}

# ---- general ----

variable "availability_domain" {
  type        = string
  description = "Name of the availability domain to launch the instance in. Leave empty to automatically pick the first availability domain available in the region."
  default     = ""
}

variable "prefix" {
  type        = string
  description = "Prefix applied to the display name of every resource this stack creates."
  default     = "openvpn-as"
}

# ---- instance ----

variable "shape" {
  type        = string
  description = "Compute shape for the Access Server instance."
  default     = "VM.Standard.E5.Flex"
}

variable "flex_ocpus" {
  type        = number
  description = "Number of OCPUs to allocate. Applies to flexible shapes."
  default     = 2
}

variable "flex_memory_in_gbs" {
  type        = number
  description = "Amount of memory in GB to allocate. Applies to flexible shapes."
  default     = 16
}

variable "boot_volume_size_in_gbs" {
  type        = number
  description = "Size of the boot volume in GB."
  default     = 50
}

variable "ssh_authorized_key" {
  type        = string
  description = "SSH public key material (not a key name) to install for instance access."
}

# ---- networking ----

variable "create_vcn" {
  type        = bool
  description = "Create a new VCN, internet gateway, route table, and public subnet. Set to false to deploy into an existing VCN and subnet named by 'existing_vcn_id' and 'existing_subnet_id'."
  default     = true
}

variable "existing_vcn_id" {
  type        = string
  description = "OCID of an existing VCN to deploy into. Only used when 'create_vcn' is false."
  default     = ""
}

variable "existing_subnet_id" {
  type        = string
  description = "OCID of an existing subnet to attach the instance to. Only used when 'create_vcn' is false."
  default     = ""
}

variable "vcn_cidr" {
  type        = string
  description = "IPv4 CIDR block for the new VCN. Only used when 'create_vcn' is true."
  default     = "10.0.0.0/16"
}

variable "subnet_cidr" {
  type        = string
  description = "IPv4 CIDR block for the new public subnet. Only used when 'create_vcn' is true."
  default     = "10.0.0.0/24"
}

variable "use_static_public_ip" {
  type        = bool
  description = "Whether to allocate a static RESERVED public IP (recommended) for the Access Server instead of relying on OCI's dynamic ephemeral public IP, which is released and reassigned across stop/start cycles."
  default     = true
}

# ---- access rules ----

variable "enable_tcp_443" {
  type        = bool
  description = "Allow inbound TCP port 443 (VPN over TCP; also required by Let's Encrypt validation)."
  default     = true
}

variable "tcp_443_source_cidr" {
  type        = string
  description = "Source CIDR permitted to reach TCP port 443."
  default     = "0.0.0.0/0"
}

variable "enable_tcp_943" {
  type        = bool
  description = "Allow inbound TCP port 943 (Admin Web UI and client web portal)."
  default     = true
}

variable "tcp_943_source_cidr" {
  type        = string
  description = "Source CIDR permitted to reach TCP port 943."
  default     = "0.0.0.0/0"
}

variable "enable_udp_1194" {
  type        = bool
  description = "Allow inbound UDP port 1194 (VPN over UDP)."
  default     = true
}

variable "udp_1194_source_cidr" {
  type        = string
  description = "Source CIDR permitted to reach UDP port 1194."
  default     = "0.0.0.0/0"
}

variable "enable_tcp_22" {
  type        = bool
  description = "Allow inbound TCP port 22 (SSH)."
  default     = true
}

variable "tcp_22_source_cidr" {
  type        = string
  description = "Source CIDR permitted to reach TCP port 22."
  default     = "0.0.0.0/0"
}

# ---- Access Server ----

variable "admin_user" {
  type        = string
  description = "Username for the OpenVPN Access Server admin account."
  default     = "openvpn"
}

variable "admin_password" {
  type        = string
  description = "Password for the OpenVPN Access Server admin account. Leave empty to generate a random password."
  default     = ""
  sensitive   = true
}

variable "enable_letsencrypt" {
  type        = bool
  description = "Automatically request and install a Let's Encrypt TLS certificate for the instance's public IP address."
  default     = true
}

# Single source of truth for the Access Server version. Bumping it for the
# marketplace path also needs new image OCIDs (mp_listing_resource_id,
# oci_images.tf). See README.md.
variable "as_version" {
  type        = string
  description = "OpenVPN Access Server version to install, e.g. 3.2.2."
  default     = "3.2.2"
}

# ---- Marketplace image (hidden group in schema.yaml: not meant for end-user editing) ----
# Only used when deployment_mode = "marketplace".

variable "mp_subscription_enabled" {
  description = "Subscribe to the OpenVPN Access Server Marketplace image listing."
  type        = bool
  default     = true
}

# Same for every release of this listing.
variable "mp_listing_id" {
  description = "OCID of the Marketplace app catalog listing for OpenVPN Access Server."
  type        = string
  default     = "ocid1.appcataloglisting.oc1..aaaaaaaafbgwdxg5j6jnyfhbcxvd62iabcraaf6bwu2u2nhrddztrrle66lq"
}

# Changes with every release. Repeated in oci_images.tf (a default must be a
# literal), so update both. tools/check-schema-drift.py fails if they differ.
# Get it with: oci marketplace package get (see README.md).
variable "mp_listing_resource_id" {
  description = "OCID of the Marketplace image for the current region."
  type        = string
  default     = "ocid1.image.oc1..aaaaaaaafdxlagrh5bnitzcdvk5cc5y44v5i5eusewbp7diufvnnicys74pa"
}
