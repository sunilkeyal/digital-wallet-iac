output "vm_public_ip" {
  value       = oci_core_instance.main.public_ip
  description = "Public IP of the compute instance (for SSH access)."
}

output "vm_private_ip" {
  value       = oci_core_instance.main.private_ip
  description = "Private IP of the compute instance."
}

output "load_balancer_public_ip" {
  value       = oci_load_balancer_load_balancer.main.ip_address_details[0].ip_address
  description = "Public IP of the load balancer (the application URL)."
}

output "application_url" {
  value       = "http://${oci_load_balancer_load_balancer.main.ip_address_details[0].ip_address}"
  description = "The public URL for the application."
}

output "storage_bucket_name" {
  value       = oci_objectstorage_bucket.main.name
  description = "Name of the OCI Object Storage bucket for deployment artifacts."
}

output "availability_domain" {
  value       = data.oci_identity_availability_domain.ad.name
  description = "The availability domain used for the compute instance."
}

output "compartment_id" {
  value       = var.compartment_ocid
  description = "The OCID of the compartment."
}
