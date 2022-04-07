# INSTALL REQUIRED PROVIDERS.

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.60.0"
    }
  }
}

provider "google" {
  # Configuration options
}

provider "google-beta" {
  # Configuration options
}


# START 

# ENABLE API's

resource "google_project_service" "project" {
  project = var.host-project-id
  service = "compute.googleapis.com"
}


# VPC
resource "google_compute_network" "private-vpc" {
  project                 = var.host-project-id
  name                    = var.vpc-name
  auto_create_subnetworks = var.vpc-subnet-creation-mode
  routing_mode            = var.vpc-routing-mode
}

# SUBNET
resource "google_compute_subnetwork" "private-vpc-subnet-us" {
  project                  = var.host-project-id
  name                     = var.vpc-subnet-name
  network                  = google_compute_network.private-vpc.id
  ip_cidr_range            = var.vpc-subnet-ip-range
  region                   = var.vpc-subnet-region
  private_ip_google_access = true
}

# GRANT SPECIFIC USERS, GROUPS OR SERVICE ACCOUNTS THE PERMISSION TO CREATE A VM WITH A PUBLIC IP
resource "google_project_iam_binding" "public-ip-admin" {
  project = var.service-project-id
  role    = "roles/compute.publicIpAdmin"
  members = [
    # list of members from the service project that should be allowed to assign public IP adresses.
  ]
}

# ROUTER
resource "google_compute_router" "private-vpc-subnet-us-router" {
  project = var.host-project-id
  name    = var.vpc-subnet-router-name
  region  = google_compute_subnetwork.private-vpc-subnet-us.region
  network = google_compute_network.private-vpc.id

  bgp {
    asn = 64514
  }
}

# NAT
resource "google_compute_router_nat" "private-vpc-subnet-us-router-nat" {
  project                            = var.host-project-id
  name                               = "private-vpc-subnet-us-router-nat"
  router                             = google_compute_router.private-vpc-subnet-us-router.name
  region                             = google_compute_router.private-vpc-subnet-us-router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}



# FIREWALL
resource "google_compute_firewall" "allow-http" {
  project   = var.host-project-id
  name      = "allow-http"
  network   = google_compute_network.private-vpc.name
  direction = "INGRESS"
  priority  = "1000"

  allow {
    protocol = "tcp"
    ports    = ["80", ]
  }
}


resource "google_compute_firewall" "allow-https" {
  project   = var.host-project-id
  name      = "allow-https"
  network   = google_compute_network.private-vpc.name
  direction = "INGRESS"
  priority  = "1000"

  allow {
    protocol = "tcp"
    ports    = ["443", ]
  }
}

resource "google_compute_firewall" "allow-rdp" {
  project   = var.host-project-id
  name      = "allow-rdp"
  network   = google_compute_network.private-vpc.name
  direction = "INGRESS"
  priority  = "65534"

  allow {
    protocol = "tcp"
    ports    = ["3389", ]
  }
}

resource "google_compute_firewall" "allow-ssh" {
  project   = var.host-project-id
  name      = "allow-ssh"
  network   = google_compute_network.private-vpc.name
  direction = "INGRESS"
  priority  = "65534"

  allow {
    protocol = "tcp"
    ports    = ["22", ]
  }
}

resource "google_compute_firewall" "private-vpc-allow-icmp" {
  project  = var.host-project-id
  name     = "allow-icmp"
  network  = google_compute_network.private-vpc.name
  priority = "65534"

  allow {
    protocol = "tcp"
  }
}

# SHARED VPC
resource "google_compute_shared_vpc_host_project" "host-project" {
  project = var.host-project-id
}

resource "google_compute_shared_vpc_service_project" "service-project" {
  host_project    = google_compute_shared_vpc_host_project.host-project.project
  service_project = var.service-project-id
}
