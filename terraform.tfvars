# VPC
vpc-name                 = "private-vpc"
vpc-routing-mode         = "GLOBAL"
vpc-subnet-creation-mode = false # auto_create_subnetworks

# SUBNET
vpc-subnet-name     = "private-vpc-subnet-us"
vpc-subnet-region   = "us-central1"
vpc-subnet-ip-range = "10.1.10.0/24"

# ROUTER
vpc-subnet-router-name = "private-vpc-subnet-us-router"

# NAT
vpc-subnet-router-nat-name = "private-vpc-subnet-us-router-nat"

# SHARED VPC
host-project-id    = "host-project-id" # project-id
service-project-id = "service-project-id"
