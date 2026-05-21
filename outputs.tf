output "vm_public_ip" {
  value       = oci_core_instance.main.public_ip
  description = "Public IP of the compute instance (for SSH access)."
}

output "vm_private_ip" {
  value       = oci_core_instance.main.private_ip
  description = "Private IP of the compute instance."
}

output "application_url" {
  value       = "http://${oci_core_instance.main.public_ip}"
  description = "The public URL for the application."
}

output "availability_domain" {
  value       = data.oci_identity_availability_domain.ad.name
  description = "The availability domain used for the compute instance."
}

output "compartment_id" {
  value       = var.compartment_ocid
  description = "The OCID of the compartment."
}
