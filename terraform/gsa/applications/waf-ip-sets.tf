resource "aws_wafv2_ip_set" "ipv4_whitelist" {
  count = contains(["staging"], terraform.workspace) ? 1 : 0

  name               = "${terraform.workspace}-ckan-ipv4-whitelist"
  description        = "${terraform.workspace}-ckan-ipv4-whitelist"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV4"
  addresses          = local.ipv4_list
}

resource "aws_wafv2_ip_set" "ipv6_whitelist" {
  count = contains(["staging"], terraform.workspace) ? 1 : 0

  name               = "${terraform.workspace}-ckan-ipv6-whitelist"
  description        = "${terraform.workspace}-ckan-ipv6-whitelist"
  scope              = "CLOUDFRONT"
  ip_address_version = "IPV6"
  addresses          = local.ipv6_list
}
