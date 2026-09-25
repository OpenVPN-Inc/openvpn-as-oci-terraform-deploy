terraform {
  # OCI Resource Manager only supports Terraform 1.5.x. Do not raise this ceiling
  # and do not use any language feature introduced after 1.5. "~> 1.5.0" alone
  # already means ">= 1.5.0, < 1.6.0" - kept as a single constraint (not the
  # equivalent compound "~> 1.5.0, < 1.6") because Resource Manager's zip-upload
  # version parser fails on the comma-separated form ("Invalid Terraform
  # version: .").
  required_version = "~> 1.5.0"

  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 6.30"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}
