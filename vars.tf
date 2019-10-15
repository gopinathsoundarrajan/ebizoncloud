variable "tenancy_ocid" {}
variable "compartment_ocid" {}
variable "region" {}

## VCN
variable "custom_dns_servers" { default = [] }
variable "dns_search_domains" { default = [] }
variable "prod_vcn_cidr" {}
variable "prod_vcn_subnets" { default = [] }
variable "transit_vcn_cidr" {}
variable "transit_vcn_sn1_cidr" {}
