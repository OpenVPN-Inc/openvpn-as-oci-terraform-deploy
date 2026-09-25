# Build-time switch. build-orm.sh rewrites the default below with sed for the
# Marketplace artifact, so keep this file single-purpose. Hidden in schema.yaml.

variable "deployment_mode" {
  type        = string
  description = "Which deployment path to use. \"ubuntu\" installs Access Server from packages.openvpn.net onto a stock Canonical Ubuntu image; \"marketplace\" launches the pre-built OpenVPN Access Server Marketplace image and only initializes it."
  default     = "ubuntu"

  validation {
    condition     = contains(["ubuntu", "marketplace"], var.deployment_mode)
    error_message = "deployment_mode must be either \"ubuntu\" or \"marketplace\"."
  }
}
