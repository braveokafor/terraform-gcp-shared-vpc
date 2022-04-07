# VPC
variable "vpc-name" {}
variable "vpc-routing-mode" {}
variable "vpc-subnet-creation-mode" {}

# SUBNET
variable "vpc-subnet-name" {}
variable "vpc-subnet-region" {}
variable "vpc-subnet-ip-range" {}

# ROUTER
variable "vpc-subnet-router-name" {}

# NAT
variable "vpc-subnet-router-nat-name" {}

# SHARED VPC
variable "host-project-id" {}
variable "service-project-id" {}
