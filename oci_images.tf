# Replication manifest expected by Oracle Marketplace tooling. Values are for
# package AS_3.2.2, same image as var.mp_listing_resource_id. compatible_shapes
# comes from `oci compute image-shape-compatibility-entry list`. Ignore the
# listing's own "compatible-architectures: ARM" metadata, it is wrong.
variable "marketplace_source_images" {
  type = map(object({
    ocid                  = string
    is_pricing_associated = bool
    compatible_shapes     = list(string)
  }))
  default = {
    main_mktpl_image = {
      ocid                  = "ocid1.image.oc1..aaaaaaaafdxlagrh5bnitzcdvk5cc5y44v5i5eusewbp7diufvnnicys74pa"
      is_pricing_associated = false
      compatible_shapes = [
        "VM.DenseIO.E4.Flex",
        "VM.DenseIO.E5.Flex",
        "VM.DenseIO.E6.Ax.Flex",
        "VM.DenseIO2.16",
        "VM.DenseIO2.24",
        "VM.DenseIO2.8",
        "VM.GPU.A10.1",
        "VM.GPU.A10.2",
        "VM.GPU.A100.40G.1",
        "VM.GPU.A100.40G.2",
        "VM.GPU.A100.40G.4",
        "VM.GPU.A100.B40G.1",
        "VM.Optimized3.Flex",
        "VM.Standard.A1.Flex",
        "VM.Standard.A2.Flex",
        "VM.Standard.A4.Flex",
        "VM.Standard.AMD.Generic",
        "VM.Standard.Ampere.Generic",
        "VM.Standard.B1.1",
        "VM.Standard.B1.16",
        "VM.Standard.B1.2",
        "VM.Standard.B1.4",
        "VM.Standard.B1.8",
        "VM.Standard.E2.1",
        "VM.Standard.E2.1.Micro",
        "VM.Standard.E2.2",
        "VM.Standard.E2.4",
        "VM.Standard.E2.8",
        "VM.Standard.E3.Flex",
        "VM.Standard.E4.Flex",
        "VM.Standard.E5.Flex",
        "VM.Standard.E6.Ax.Flex",
        "VM.Standard.E6.Flex",
        "VM.Standard.Intel.Generic",
        "VM.Standard.x86.Generic",
        "VM.Standard1.1",
        "VM.Standard1.16",
        "VM.Standard1.2",
        "VM.Standard1.4",
        "VM.Standard1.8",
        "VM.Standard2.1",
        "VM.Standard2.16",
        "VM.Standard2.2",
        "VM.Standard2.24",
        "VM.Standard2.4",
        "VM.Standard2.8",
        "VM.Standard3.Flex",
        "VM.Standard4.Ax.Flex",
        "BM.Standard.A1.160",
        "BM.DenseIO.A4.Ax.72",
        "BM.Standard.A4.48",
        "BM.Standard.A4.Ax.48",
        "BM.Standard.E2.64",
        "BM.Standard.E3.128",
        "BM.Standard.E4.128",
        "BM.DenseIO.E4.128",
        "BM.DenseIO.E5.128",
        "BM.HPC.E5.144",
        "BM.Standard.E5.192",
        "BM.Standard.E6.Ax.192",
        "BM.DenseIO.E6.Ax.192",
        "BM.Standard.E6.256",
        "BM.Standard1.36",
        "BM.Standard.B1.44",
        "BM.Standard2.52",
        "BM.Optimized3.36",
        "BM.Standard3.64",
        "BM.GPU.A10.4",
      ]
    }
  }
}
