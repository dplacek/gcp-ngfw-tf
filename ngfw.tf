# GCP Marketplace VM-series Image
data "google_compute_image" "vm_series" {
  name    = var.ngfw_image_name
  project = var.ngfw_image_project
}

# Deploy NGFWs
resource "google_compute_instance" "ngfw" {
  count                     = 2
  name                      = "prod-usc1-vm-ngfw-${count.index + 1}"
  machine_type              = var.ngfw_instance_size
  zone                      = var.ngfw_zones[count.index]
  can_ip_forward            = true
  allow_stopping_for_update = true

  metadata = {
    # init-cfg
    hostname                    = "prod-usc1-vm-ngfw-${count.index + 1}"
    serial-port-enable          = true
    ssh-keys                    = tls_private_key.ngfw.public_key_openssh
    type                        = "dhcp-client"
    panorama-server             = ""
    panorama-server-2           = ""
    tplname                     = ""
    dgname                      = ""
    dns-primary                 = "1.1.1.1"
    dns-secondary               = "8.8.8.8"
    op-command-modes            = "mgmt-interface-swap"
    mgmt-interface-swap         = "enable"
    op-cmd-dpdk-pkt-io          = "on"
    dhcp-send-hostname          = "yes"
    dhcp-send-client-id         = "yes"
    dhcp-accept-server-hostname = "yes"
    dhcp-accept-server-domain   = "yes"
  }

  service_account {
    scopes = ["https://www.googleapis.com/auth/cloud.useraccounts.readonly",
              "https://www.googleapis.com/auth/devstorage.read_only",
              "https://www.googleapis.com/auth/logging.write",
              "https://www.googleapis.com/auth/monitoring.write"]
  }

  network_interface { # Some External Load Balancer configurations require traffic delivery to nic0
    subnetwork    = google_compute_subnetwork.untrust.self_link
    access_config {} # Required to obtain public IP
  }
  network_interface {
    subnetwork    = google_compute_subnetwork.mgmt.self_link
    access_config {} # Required to obtain public IP
  }
  network_interface {
    subnetwork = google_compute_subnetwork.trust.self_link
  }

  tags = ["ngfw"]

  boot_disk {
    auto_delete = false
    device_name = "prod-usc1-disk-ngfw-${count.index + 1}"
    initialize_params {
      image = data.google_compute_image.vm_series.self_link
      type = "pd-ssd"
    }
  }
}

# One instance group per zone
# Used for ILB backend
resource "google_compute_instance_group" "ngfw" {
  count     = 2
  name      = "prod-usc1-ig-ngfw-${var.ngfw_zones[count.index]}"
  instances = [google_compute_instance.ngfw[count.index].self_link]
  zone      = var.ngfw_zones[count.index]
}

# Allow HTTPS and SSH to management interface from management CIDRs
resource "google_compute_firewall" "mgmt" {
  name    = "prod-usc1-fwrule-ngfw-mgmt"
  network = google_compute_network.mgmt.self_link

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["443", "22"]
  }

  source_ranges = concat(var.management_internal, var.management_external)
}

# Allow all traffic into the Untrust interface
resource "google_compute_firewall" "untrust" {
  name    = "prod-usc1-fwrule-ngfw-untrust"
  network = google_compute_network.untrust.self_link

  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}

# Allow all traffic into the Trust interface
resource "google_compute_firewall" "trust" {
  name    = "prod-usc1-fwrule-ngfw-trust"
  network = google_compute_network.trust.self_link

  allow {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}

# Set default route for Trust VPC
resource "google_compute_route" "trust_default" {
  name         = "prod-usc1-route-trust-default"
  dest_range   = "0.0.0.0/0"
  network      = google_compute_network.trust.self_link
  next_hop_ilb = google_compute_forwarding_rule.ngfw.id
  priority     = 100
}