locals {
  prod_vcn_namespace           = "ORA-VCN-USASH1-PRODSPOKE-2"
  prod_vcn_availability_domain = local.availability_domains[0]["name"]
}

resource "oci_core_vcn" "prod" {
  display_name   = "${local.prod_vcn_namespace}"
  compartment_id = var.compartment_ocid
  cidr_block     = var.prod_vcn_cidr
  dns_label      = "oravcnusash1pro"
}

resource "oci_core_dhcp_options" "prod" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.prod.id
  display_name   = "${local.prod_vcn_namespace}-DHCP-1"
  options {
    type               = "DomainNameServer"
    server_type        = "CustomDnsServer"
    custom_dns_servers = var.custom_dns_servers
  }
  options {
    type                = "SearchDomain"
    search_domain_names = var.dns_search_domains
  }
}

resource "oci_core_route_table" "prod" {
  display_name   = "${local.prod_vcn_namespace}-RT-DefaultSN-1"
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.prod.id

  route_rules {
    network_entity_id = "${oci_core_local_peering_gateway.prod.id}"
    destination       = "0.0.0.0/0" //var.prod_vcn_cidr
    destination_type  = "CIDR_BLOCK"
  }

  route_rules {
    network_entity_id = "${oci_core_service_gateway.prod.id}"
    destination       = "all-iad-services-in-oracle-services-network"
    destination_type  = "SERVICE_CIDR_BLOCK"
  }
}

resource "oci_core_default_security_list" "prod" {
  manage_default_resource_id = oci_core_vcn.prod.default_security_list_id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "all"
    source   = "0.0.0.0/0"
  }
}

resource "oci_core_security_list" "prod" {
  display_name   = "${local.prod_vcn_namespace}-NSG-DefaultSN-1"
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.prod.id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "all"
    source   = "0.0.0.0/0"
  }
}

resource "oci_core_subnet" "prod" {
  display_name               = "${local.prod_vcn_namespace}-SN-${element(var.prod_vcn_subnets, count.index).name}"
  count                      = length(var.prod_vcn_subnets)
  cidr_block                 = element(var.prod_vcn_subnets, count.index).cidr
  dns_label                  = lookup(element(var.prod_vcn_subnets, count.index), "dns", "")
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.prod.id
  route_table_id             = oci_core_route_table.prod.id
  security_list_ids          = [oci_core_default_security_list.prod.id]
  dhcp_options_id            = lookup(local.dhcp, lookup(element(var.prod_vcn_subnets, count.index), "dhcp", "dhcp1"), "")
  prohibit_public_ip_on_vnic = true
  #availability_domain = local.prod_vcn_availability_domain
}

resource "oci_core_service_gateway" "prod" {
  display_name   = "${local.prod_vcn_namespace}-SGW-1"
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.prod.id
  services {
    service_id = "${data.oci_core_services.services.services.1.id}"
  }
}

resource "oci_core_local_peering_gateway" "prod" {
  display_name   = "PG-ORA-ASH-LGW2HUB-2"
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.prod.id

  //peer_id = "${oci_core_local_peering_gateway.transit.id}"
  route_table_id = "${oci_core_vcn.prod.default_route_table_id}"
}

locals {
  dhcp = {
    default = oci_core_vcn.prod.default_dhcp_options_id
    dhcp1   = oci_core_dhcp_options.prod.id
  }
}
