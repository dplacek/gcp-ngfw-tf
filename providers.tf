terraform {
  # Configure Terraform Backend to use Google Cloud Storage
  backend "gcs" {}
  # Configure Terraform Providers
  required_providers {
    # GCP Provider
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0" # Latest 5.X Version
    }
  }
}

# Configure the GCP Provider
provider "google" {
  project     = "sandbox"
  region      = "us-central1"
}