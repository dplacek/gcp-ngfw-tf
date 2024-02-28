# Forward all TCP, UDP, ICMP traffic to NGFWs
# Although forwarding rule is TCP only, when a default route is pointed to an ILB, all L3 traffic is forwarded
# https://cloud.google.com/load-balancing/docs/internal#next-hops
resource "google_compute_forwarding_rule" "ngfw" {
  name                  = "prod-usc1-ilb-ngfw"
  region                = "us-central1"
  network               = google_compute_network.trust.self_link
  subnetwork            = google_compute_subnetwork.trust.self_link
  load_balancing_scheme = "INTERNAL"
  backend_service       = google_compute_region_backend_service.ngfw.self_link
  ip_protocol           = "TCP"
  all_ports             = true
  service_label         = "prod-usc1-ilb-ngfw"
}

# NGFW Backend
# One backend per zone
resource "google_compute_region_backend_service" "ngfw" {
  name             = "prod-usc1-ilb-ngfw"
  region           = "us-central1"
  network          = google_compute_network.trust.self_link
  protocol         = "TCP"
  timeout_sec      = 10
  session_affinity = "CLIENT_IP_PORT_PROTO"
  health_checks    = [google_compute_health_check.ngfw.id]

  backend {
    group = google_compute_instance_group.ngfw[0].self_link
    failover = true
  }
  backend {
    group = google_compute_instance_group.ngfw[1].self_link
  }
}

# HTTP Health Check
resource "google_compute_health_check" "ngfw" {
  name    = "prod-usc1-hc-ngfw"

  timeout_sec         = 5
  check_interval_sec  = 15
  healthy_threshold   = 4
  unhealthy_threshold = 2

  tcp_health_check {
    port = "80"
  }
}