# Trust
resource "google_compute_network" "trust" {
  name                    = "prod-usc1-vpc-trust"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_subnetwork" "trust" {
  name          = "prod-usc1-subnet-trust"
  ip_cidr_range = "10.10.1.0/24"
  network       = google_compute_network.trust.id
  region        = "us-central1"
}

# Untrust
resource "google_compute_network" "untrust" {
  name                    = "prod-usc1-vpc-untrust"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_subnetwork" "untrust" {
  name          = "prod-usc1-subnet-untrust"
  ip_cidr_range = "10.10.2.0/24"
  network       = google_compute_network.untrust.id
  region        = "us-central1"
}

# Management
resource "google_compute_network" "mgmt" {
  name                    = "prod-usc1-vpc-mgmt"
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

resource "google_compute_subnetwork" "mgmt" {
  name          = "prod-usc1-subnet-mgmt"
  ip_cidr_range = "10.10.0.0/24"
  network       = google_compute_network.mgmt.id
  region        = "us-central1"
}
