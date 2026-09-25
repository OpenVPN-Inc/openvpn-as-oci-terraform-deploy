# OpenVPN Access Server Deployment on Oracle Cloud Infrastructure Using Terraform

This repository deploys **OpenVPN Access Server** on Oracle Cloud Infrastructure (OCI): a Compute instance, a VCN/subnet (or attachment to an existing one), a network security group with rules for the VPN and admin ports, a reserved or ephemeral public IP, and (optionally) a Let's Encrypt certificate requested at first boot.

## The module

The Terraform module lives at the **repository root**. A single variable, `deployment_mode`, selects how Access Server gets onto the instance:

| `deployment_mode` | Image | How Access Server arrives |
|---|---|---|
| `ubuntu` (default) | Stock Canonical Ubuntu 24.04 Minimal, found via a `data.oci_core_images` lookup | Installed at first boot from `packages.openvpn.net`. Needs outbound internet access. |
| `marketplace` | The published OpenVPN Access Server Marketplace image, pinned by OCID | Already installed on the image; cloud-init only runs `ovpn-init` and configures it. Downloads nothing at deploy time. |

Everything else - networking, security rules, public IP handling, admin credentials, Let's Encrypt, and all outputs - is identical across both paths.

`deployment_mode` selects the image and decides whether the app-catalog subscription resources are created. It does **not** branch the cloud-init script: `scripts/cloud-config.yaml` is a single file that picks its path at boot by probing for `/usr/bin/ovpn-init`, which exists only on the Marketplace image. Present means "already installed, just initialize"; absent means "stock Ubuntu, install it".

### Access Server version

`var.as_version` (default `3.2.2`) is the single source of truth. It feeds the installer's `--as-version` flag on the ubuntu path, and `local.mp_listing_resource_version` derives the `AS_<version>` Marketplace package name from it.

Two things it does **not** update automatically, both of which must be changed by hand when bumping it:

- `schema.yaml`'s `version:` field - plain YAML, so it cannot reference a Terraform variable.
- The pinned image OCIDs in `mp_listing_resource_id` and `oci_images.tf`, which belong to one specific package version. Bumping `as_version` without refreshing those leaves the marketplace path pointing a new package version at an old image.

`deployment_mode` is a **build-time** switch, not a customer-facing choice. A Marketplace customer must always get the marketplace path and a quick-deploy user always the ubuntu path, so it sits in `schema.yaml`'s hidden variable group and is pinned when the artifact is packaged (below).

### Networking default

The console form defaults to **deploying into an existing VCN and subnet**: `schema.yaml` sets `create_vcn: false`, so the "Existing VCN" and "Existing subnet" dropdowns are shown and required from the start. Tick "Create a new VCN" to have the stack build a VCN, internet gateway, route table and public subnet instead.

Note this default is set in `schema.yaml` only. `variables.tf` has `create_vcn = true`, so a bare local `terraform apply` with no overrides creates a throwaway VCN rather than failing on unset OCIDs. Set `create_vcn = false` plus `existing_vcn_id` / `existing_subnet_id` in your tfvars to match the console behaviour.

### Local CLI use

Resource Manager injects its own provider configuration into a stack, so no live `provider.tf` is committed. For local use, copy the inert one:

```bash
cp provider.tf.cli provider.tf     # gitignored; excluded from every artifact
terraform init
terraform apply                    # defaults to deployment_mode = "ubuntu"
```

## Building the stack artifacts

`packaging/build-orm.sh` produces the flat zip Resource Manager and Marketplace require (`.tf` files and `schema.yaml` at the **zip root**, `scripts/` beneath):

```bash
./packaging/build-orm.sh ubuntu        # -> dist/orm-ubuntu.zip
./packaging/build-orm.sh marketplace   # -> dist/orm-marketplace.zip
```

The script copies an allow-list of the module's own files, so nothing else in the repository can leak into an artifact. For the marketplace build it additionally rewrites the `deployment_mode` default to `"marketplace"`, then **asserts the rewrite landed** and aborts if not - without that guard, a formatting change to `deployment_mode.tf` would make the substitution a silent no-op and ship a Marketplace artifact that launches a stock Ubuntu image.

`dist/` is gitignored.

### Deploying a zip from a URL

Resource Manager can build a stack straight from a published zip:

```
https://cloud.oracle.com/resourcemanager/stacks/create?region=home&zipUrl=<URL to orm-ubuntu.zip>
```

## Refreshing the Marketplace OCIDs

`mp_listing_id`, `mp_listing_resource_version`, and `mp_listing_resource_id` in `variables.tf` (plus the image OCID and `compatible_shapes` in `oci_images.tf`) pin a specific published listing package. After the listing is republished under a new version:

```bash
oci marketplace listing get --listing-id <listing OCID>          # note default-package-version
oci marketplace package get --listing-id <listing OCID> --package-version <new version>
oci compute image-shape-compatibility-entry list --image-id <image OCID>
```

Do not trust the listing's own `compatible-architectures` metadata - it is currently wrong on the live listing (it claims ARM-only). `oci compute image-shape-compatibility-entry list` is authoritative.

## Ports

| Port | Protocol | Purpose |
|---|---|---|
| 943 | TCP | Admin Web UI and Client Web Portal |
| 443 | TCP | VPN over TCP; also required by Let's Encrypt to validate the instance |
| 1194 | UDP | VPN over UDP (preferred transport) |
| 22 | TCP | SSH |

Each port can be disabled and its source CIDR restricted independently. It is strongly recommended to restrict TCP 22 (SSH) to the administrator's own IP address rather than leaving it open to `0.0.0.0/0`.

## Terraform version

OCI Resource Manager only supports Terraform **1.5.x**, enforced by `required_version = "~> 1.5.0"` in `versions.tf`. Do not raise that ceiling and do not use any language feature introduced after 1.5, even for local-only use. Keep it as a single constraint: Resource Manager's zip-upload parser fails on the equivalent comma-separated compound form with `Invalid Terraform version: .`
