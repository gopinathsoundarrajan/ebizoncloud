
data "oci_identity_availability_domains" "list" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_services" "services" {
}

locals {
  availability_domains = data.oci_identity_availability_domains.list.availability_domains
}
