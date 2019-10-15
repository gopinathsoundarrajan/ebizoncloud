
locals {
  transit_vcn_namespace           = "ORA-VCN-USASH1-TRANSHUB-1"
  transit_vcn_availability_domain = local.availability_domains[0]["name"]
}

resource "oci_core_vcn" "transit" {
  display_name   = "${local.transit_vcn_namespace}"
  compartment_id = var.compartment_ocid
  cidr_block     = var.transit_vcn_cidr
  dns_label      = "oravcnusash1tra"
}

resource "oci_core_default_dhcp_options" "transit" {
  manage_default_resource_id = oci_core_vcn.transit.default_dhcp_options_id
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

resource "oci_core_default_route_table" "transit" {
  manage_default_resource_id = oci_core_vcn.transit.default_route_table_id

  route_rules {
    network_entity_id = "${oci_core_local_peering_gateway.transit.id}"
    destination       = var.prod_vcn_cidr
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_route_table" "transit_rt1" {
  display_name   = "PG-ORA-ASH-LGWHUB-1-RT-1"
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.transit.id

  route_rules {
    network_entity_id = "${oci_core_drg.transit_drg1.id}"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_route_table" "transit_rt2" {
  display_name   = "PG-ORA-ASH-LGWHUB-1-RT-2"
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.transit.id

  route_rules {
    network_entity_id = "${oci_core_drg.transit_drg1.id}"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_subnet" "transit_vcn_sn1" {
  display_name               = "${local.transit_vcn_namespace}-SN-HUB-1"
  cidr_block                 = var.transit_vcn_sn1_cidr
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.transit.id
  route_table_id             = oci_core_route_table.transit_rt1.id
  security_list_ids          = [oci_core_default_security_list.transit.id]
  dhcp_options_id            = oci_core_vcn.transit.default_dhcp_options_id
  prohibit_public_ip_on_vnic = true
  #availability_domain = local.transit_vcn_availability_domain
}

resource "oci_core_default_security_list" "transit" {
  manage_default_resource_id = oci_core_vcn.transit.default_security_list_id

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "6" # tcp
    source   = "0.0.0.0/0"

    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol = "1" # icmp
    source   = "0.0.0.0/0"

    icmp_options {
      type = 3
      code = 4
    }
  }

  ingress_security_rules {
    protocol = "1" # icmp
    source   = var.transit_vcn_cidr

    icmp_options {
      type = 3
    }
  }
}

resource "oci_core_drg" "transit_drg1" {
  display_name   = "PG-ORA-ASH-DRG-1"
  compartment_id = var.compartment_ocid
}

resource "oci_core_drg_attachment" "transit_drg1" {
  drg_id         = "${oci_core_drg.transit_drg1.id}"
  vcn_id         = "${oci_core_vcn.transit.id}"
  route_table_id = "${oci_core_route_table.transit_drg1.id}"
}

resource "oci_core_route_table" "transit_drg1" {
  display_name   = "PG-ORA-ASH-DRG-1-RT-1"
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.transit.id

  route_rules {
    network_entity_id = "${oci_core_local_peering_gateway.transit.id}"
    destination       = var.prod_vcn_cidr
    destination_type  = "CIDR_BLOCK"
  }
}

resource "oci_core_local_peering_gateway" "transit" {
  display_name   = "PG-ORA-ASH-LGW2PROD-2"
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.transit.id

  peer_id        = "${oci_core_local_peering_gateway.prod.id}"
  route_table_id = "${oci_core_route_table.transit_rt2.id}"
}
