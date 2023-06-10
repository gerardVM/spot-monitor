terraform {
  required_version = ">= 1.4.4"
  
  required_providers {
    zerotier = {
      source = "zerotier/zerotier"
      version = "1.4.0"
    }
  }

  backend "s3" {
    bucket    = "spot-monitor-tfstate"
    key       = "zerotier/terraform.tfstate"
    region    = "eu-west-3"
    encrypt   = true
  }
}

provider "zerotier" {}

resource "zerotier_network" "network" {
  name        = local.zerotier.network_name
  description = "Managed by Terraform"

  assign_ipv4 {
    zerotier = true
  }

  assign_ipv6 {
    zerotier = false
    sixplane = false
    rfc4193  = false
  }

  enable_broadcast = true
  private          = true
  flow_rules       = "accept;"
}

resource "zerotier_member" "member" {
  for_each = { for member in local.zerotier.members : member.name => member }

  network_id              = zerotier_network.network.id
  
  name                    = each.value.name
  member_id               = each.value.id
  ip_assignments          = each.value.ip_assignments
  authorized              = true

}