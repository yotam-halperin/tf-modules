# AWS VPC Peering Connection Module

This module configures VPC peering in different configurations.

These types of resources are supported:
* AWS VPC Peering Connection
* AWS VPC Peering Connection Accepter
* AWS VPC Peering Connection Options
* AWS Route


## Important Notice

* \* - There is a bug with applying VPC peering options currently. You can still specify and manage them with this module, but you will need to run `apply` twice.
* Version `v3.1.*` supports both Terraform `0.14` and `0.15.0`. However, it throws warnings regarding empty providers deprecation. Provider configuration was changed in Terraform `0.15.0`. Therefore, newer versions would likely be incompatible with Terraform `<=0.15`. So, if you need to use both Terraofmr `0.14` and `0.15` at the same time or you're in the process of migration, please, use `v3.1.*` of this module.

## Features

This module configures VPC peering between two VPCs. Cross-account and cross-region configurations are supported as well.

You can also manage peering options, but you need to run `apply` twice to do that.

## Terraform Versions

**Always make sure you pinned the module version!**

* For Terraform versions `>=0.15` use `v4.*` versions of this module
* For Terraform versions `>=0.13` use `v3.*` versions of this module
* For Terraform versions `>=0.12 <0.13` use `v2.*` versions of this module
* If you're still using Terraform `0.11`, you can use `v1.*` versions of this module

## Usage

### Simple Peering (single AWS account, same region)
**Notice**: You need to declare both providers even with single region peering.

```
module "single_account_single_region" {
  source = "../../"

  providers = {
    aws.this = aws
    aws.peer = aws
  }

  this_vpc_id = var.this_vpc_id
  peer_vpc_id = var.peer_vpc_id

  auto_accept_peering = true

  tags = {
    Name        = "tf-single-account-single-region"
    Environment = "Test"
  }
}
```
# Inputs

|Name|Description|Type|Default|Required|
|----|-----------|----|-------|--------|
|peer_vpc_id|Peer VPC ID: string|string|""||
|this_vpc_id|This VPC ID: string|string|""||
|auto_accept_peering|Auto accept peering connection: bool|bool|false||
|tags|Tags: map|map(string)|{}||
|peer_dns_resolution|Indicates whether a local VPC can resolve public DNS hostnames to private IP addresses when queried from instances in a peer VPC|bool|false||
|peer_link_to_peer_classic|Indicates whether a local ClassicLink connection can communicate with the peer VPC over the VPC Peering Connection|bool|false||
|peer_link_to_local_classic|Indicates whether a local VPC can communicate with a ClassicLink connection in the peer VPC over the VPC Peering Connection|bool|false||
|this_dns_resolution|Indicates whether a local VPC can resolve public DNS hostnames to private IP addresses when queried from instances in a this VPC|bool|false||
|this_link_to_peer_classic|Indicates whether a local ClassicLink connection can communicate with the this VPC over the VPC Peering Connection|bool|false||
|this_link_to_local_classic|Indicates whether a local VPC can communicate with a ClassicLink connection in the this VPC over the VPC Peering Connection|bool|false||
|from_this|If traffic TO peer vpc (from this) should be allowed|bool|true||
|from_peer|If traffic FROM peer vpc (to this) should be allowed|bool|true||
|peer_subnets_ids|If communication can only go to some specific subnets of peer vpc. If empty whole vpc cidr is allowed|list(string)|[]||
|this_subnets_ids|If communication can only go to some specific subnets of this vpc. If empty whole vpc cidr is allowed|list(string)|[]||
|this_rts_ids|Allows to explicitly specify route tables for this VPC|list(string)|[]||
|peer_rts_ids|Allows to explicitly specify route tables for peer VPC|list(string)|[]||


# Outputs

|Name|Description|
|----|-----------|
|aws_vpc_peering_connection||
|aws_vpc_peering_connection_accepter||
|vpc_peering_id|Peering connection ID||
|vpc_peering_accept_status|Accept status for the connection|
|peer_vpc_id|The ID of the accepter VPC|
|this_vpc_id|The ID of the requester VPC|
|this_owner_id|The AWS account ID of the owner of the requester VPC|
|peer_owner_id|The AWS account ID of the owner of the accepter VPC|
|peer_region|The region of the accepter VPC|
|accepter_options|VPC Peering Connection options set for the accepter VPC|
|requester_options|VPC Peering Connection options set for the requester VPC|
|requester_routes|Routes from the requester VPC|
|accepter_routes|Routes to the accepter VPC|