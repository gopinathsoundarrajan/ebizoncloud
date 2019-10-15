

region = "us-ashburn-1"

custom_dns_servers = ["143.26.128.29", "192.44.120.10"]
dns_search_domains = ["np-cloud-pg.com"]

transit_vcn_cidr = "137.181.41.240/28"
transit_vcn_sn1_cidr = "137.181.41.240/29"

prod_vcn_cidr = "137.181.40.0/24"
prod_vcn_subnets = [
  {
    name = "TerraAML-1"
    cidr = "137.181.40.112/29"
  },
  {
    name = "OBIEE-1"
    cidr = "137.181.40.120/29"
  },
  {
    name = "OAE01Backup"
    cidr = "137.181.40.32/28"
    dns = "oae01backup"
    dhcp = "default"
  },
  {
    name = "OAE01Client"
    cidr = "137.181.40.16/28"
    dns = "oae01client"
    dhcp = "default"
  },
  {
    name = "OptTxInterface-1"
    cidr = "137.181.40.208/28"
  },
  {
    name = "OptExaClient-1"
    cidr = "137.181.40.224/29"
    dhcp = "default"
  },
  {
    name = "OptExaBackup-1"
    cidr = "137.181.40.232/29"
    dns = "optexabk01"
  },
  {
    name = "ADWETL-1"
    cidr = "137.181.40.96/28"
  },
  {
    name = "TerraExaBackup-1"
    cidr = "137.181.40.88/29"
    dns = "terraexabk01"
  },
  {
    name = "TerraExaClient-1"
    cidr = "137.181.40.80/29"
    dns = "terraexacl01"
  },
  {
    name = "OEM-1"
    cidr = "137.181.40.0/28"
  },
  {
    name = "OptTxWE-1"
    cidr = "137.181.40.144/28"
  },
  {
    name = "OptTxLA-1"
    cidr = "137.181.40.160/28"
  },
  {
    name = "OptTxCEEMEA-1"
    cidr = "137.181.40.192/28"
  },
  {
    name = "OptTxAP-1"
    cidr = "137.181.40.176/28"
  },
  {
    name = "NetworkTest-1"
    cidr = "137.181.40.248/29"
  },
  {
    name = "TerraGUI-1"
    cidr = "137.181.40.48/28"
  },
  {
    name = "TerraETL-1"
    cidr = "137.181.40.64/28"
  },
  {
    name = "OptAnalytics-1"
    cidr = "137.181.40.128/28"
  }
]