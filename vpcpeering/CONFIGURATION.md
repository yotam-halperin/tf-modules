# VPC Peering MODULE CONFIGURATION
This module using additional aws provider, it's mean we cannot call to this base module directly from terragrunt and need to use wrapper
## Prerequisite 
##### Create IAM role in each accept peering account (for example mgmt, shared-services, org-root and atc)
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "ec2:ReplaceRouteTableAssociation",
                "ec2:DeleteTags",
                "ec2:DeleteVpcPeeringConnection",
                "ec2:AcceptVpcPeeringConnection",
                "ec2:CreateTags",
                "ec2:DescribeVpcPeeringConnections",
                "ec2:DeleteRoute",
                "ec2:DisassociateRouteTable",
                "ec2:ReplaceRoute",
                "ec2:RejectVpcPeeringConnection",
                "ec2:AssociateRouteTable",
                "ec2:CreateRoute",
                "ec2:ModifyVpcPeeringConnectionOptions",
                "ec2:CreateVpcPeeringConnection",
                "ec2:DescribeRouteTables"
            ],
            "Resource": "*"
        }
    ]
}
```
##### Create provider
Add to generate "main_providers" block in the main terragrunt.hcl file new provider per peering account

```json
provider "aws" {
  alias   = "mgmt"
  region = var.aws_region
  assume_role {
    role_arn     = "<role_arn>"
    session_name = "mgmtprovider"
  }
}
```
##### wrapper example configuration
```josn
module "vpc_peering_management_account" {
  source = "git::https://bitbucket.org/commitcloud360/priority-terraform-modules//vpc-peering?ref=v0.1.0"

  providers = {
    aws.peer = aws.mgmt
  }

  this_vpc_id         = var.this_vpc_id
  peer_vpc_id         = var.mgmt_vpc_id
  auto_accept_peering = true
  this_dns_resolution = true
  peer_dns_resolution = true

  tags = var.common_tags
}
```

## General Configuration
```terraform
this_vpc_id = dependency.vpc.outputs.vpc_id
peer_vpc_id = vpc-00b46a898be66a576
```
## Request VPC configuration
```terraform
this_dns_resolution        = true
this_link_to_peer_classic  = true
this_link_to_local_classic = true
```
## Accept VPC configuration
```terraform
peer_dns_resolution        = true
peer_link_to_peer_classic  = true
peer_link_to_local_classic = true
```
## If communication can only go to some specific subnets of peer vpc. If empty whole vpc cidr is allowed
```terraform
peer_subnets_ids = []
```
## If communication can only go to some specific subnets of this vpc. If empty whole vpc cidr is allowed
```terraform
this_subnets_ids = []
```
## Allows to explicitly specify route tables for this VPC
```terraform
this_rts_ids = []
```
## Allows to explicitly specify route tables for peer VPC
```terraform
peer_rts_ids = []
```