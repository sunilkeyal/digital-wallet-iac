resource "oci_objectstorage_bucket" "main" {
  compartment_id = var.compartment_ocid
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  name           = "${local.display_name}-artifacts"
  access_type    = "NoPublicAccess"
  storage_tier   = "Standard"

  freeform_tags = local.common_tags
}

data "oci_objectstorage_namespace" "ns" {
  compartment_id = var.compartment_ocid
}
