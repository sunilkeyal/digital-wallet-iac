resource "oci_load_balancer_load_balancer" "main" {
  compartment_id = var.compartment_ocid
  display_name   = "${local.display_name}-lb"
  shape          = "flexible"

  shape_details {
    minimum_bandwidth_in_mbps = 10
    maximum_bandwidth_in_mbps = 10
  }

  subnet_ids = [oci_core_subnet.public.id]

  freeform_tags = local.common_tags
}

resource "oci_load_balancer_backend_set" "main" {
  name             = "${local.display_name}-bs"
  load_balancer_id = oci_load_balancer_load_balancer.main.id
  policy           = "ROUND_ROBIN"

  health_checker {
    protocol          = "HTTP"
    port              = 80
    url_path          = "/health"
    interval_ms       = 10000
    retries           = 3
    return_code       = 200
    timeout_in_millis = 5000
  }
}

resource "oci_load_balancer_listener" "http" {
  load_balancer_id         = oci_load_balancer_load_balancer.main.id
  name                     = "${local.display_name}-http"
  default_backend_set_name = oci_load_balancer_backend_set.main.name
  port                     = 80
  protocol                 = "HTTP"
}

resource "oci_load_balancer_backend" "main" {
  backendset_name  = oci_load_balancer_backend_set.main.name
  load_balancer_id = oci_load_balancer_load_balancer.main.id
  ip_address       = oci_core_instance.main.private_ip
  port             = 80
  backup           = false
  drain            = false
  offline          = false
  weight           = 1
}
