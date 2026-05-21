resource "oci_core_instance" "main" {
  availability_domain = data.oci_identity_availability_domain.ad.name
  compartment_id      = var.compartment_ocid
  display_name        = "${local.display_name}-vm"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = 2
    memory_in_gbs = 12
  }

  create_vnic_details {
    subnet_id              = oci_core_subnet.public.id
    display_name           = "${local.display_name}-vnic"
    assign_public_ip       = true
    skip_source_dest_check = true
    nsg_ids                = [oci_core_network_security_group.compute.id]
  }

  source_details {
    source_type = "image"
    source_id   = data.oci_core_images.ubuntu.images[0].id
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data           = base64encode(templatefile("${path.module}/scripts/cloud-init.yaml", {
      jwt_secret         = var.jwt_secret
      jwt_expiration     = var.jwt_expiration
      app_admin_username = var.app_admin_username
      app_admin_password = var.app_admin_password
      app_admin_email    = var.app_admin_email
      oci_region         = var.region
      oci_namespace      = data.oci_objectstorage_namespace.ns.namespace
      docker_image_tag   = var.docker_image_tag
    }))
  }

  freeform_tags = local.common_tags
}

data "oci_core_images" "ubuntu" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "oci_core_network_security_group" "compute" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.main.id
  display_name   = "${local.display_name}-compute-nsg"
}

resource "oci_core_network_security_group_security_rule" "compute_ingress_http" {
  network_security_group_id = oci_core_network_security_group.compute.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  description               = "Allow HTTP"
  tcp_options {
    destination_port_range {
      min = 80
      max = 80
    }
  }
}

resource "oci_core_network_security_group_security_rule" "compute_ingress_ssh" {
  network_security_group_id = oci_core_network_security_group.compute.id
  direction                 = "INGRESS"
  protocol                  = "6"
  source                    = "0.0.0.0/0"
  description               = "Allow SSH"
  tcp_options {
    destination_port_range {
      min = 22
      max = 22
    }
  }
}

resource "oci_core_network_security_group_security_rule" "compute_egress_all" {
  network_security_group_id = oci_core_network_security_group.compute.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
  description               = "Allow all outbound"
}
