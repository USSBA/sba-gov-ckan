# ZScaler IP Addresses
# ------------------------------
# This will grab the IP address for the Americas for the US Government
# and place them into IPV4 and IPV6 list accordingly

data "http" "ip_list" {
  url = "https://api.config.zscaler.com/zscalergov.net/cenr/json"
  request_headers = {
    Accept = "application/json"
  }
}

locals {
  ipv4_regex = "\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}/\\d{1,2}"
  json       = jsondecode(data.http.ip_list.response_body) # The json reponse, converted to terraform object.
  key_1      = keys(local.json)[0]                         # First key in json response ("zscalergov.net").
  key_2      = keys(local.json[local.key_1])[0]            # Second key in json response ("continent : Americas").
  ipv4_list = sort(
    concat(
      flatten(
        [
          # Third key in json response ("city : <city_name>").
          for key_3 in keys(local.json[local.key_1][local.key_2]) : [
          for key, value in local.json[local.key_1][local.key_2][key_3] : value.range if length(regexall(local.ipv4_regex, value.range)) > 0]
        ]
      ),
      # AT&T Global VPN IP Addresses
      ["165.110.5.64/32", "165.110.5.65/32", "165.110.5.66/32", "165.110.5.67/32"]
    )
  )
  ipv6_list = sort(
    flatten(
      [
        # Third key in json response ("city : <city_name>").
        for key_3 in keys(local.json[local.key_1][local.key_2]) : [
        for key, value in local.json[local.key_1][local.key_2][key_3] : value.range if length(regexall(local.ipv4_regex, value.range)) == 0]
      ]
    )
  )
}
