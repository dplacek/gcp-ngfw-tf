
# SSH Key for VM-series Instances
resource "tls_private_key" "ngfw" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# NGFW SSH Private Key (PEM)
resource "google_secret_manager_secret" "ngfw" {
  secret_id = "prod-usc1-sshkey-ngfw"
  replication {
    auto {}
  }
}

# NGFW SSH Private Key (PEM)
resource "google_secret_manager_secret_version" "ngfw" {
  secret      = google_secret_manager_secret.ngfw.id
  secret_data = tls_private_key.ngfw.private_key_pem
}

# Output SSH Private Key
output "ssh_private_key" {
  value = nonsensitive(tls_private_key.ngfw.private_key_pem)
}