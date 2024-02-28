variable "ngfw_instance_size" {
  description = "NGFW Instance Size"
  default     = "c2-standard-4" # Compute Optimized - 4 vCPU, 16GB RAM
}

variable "ngfw_zones" {
  description = "Zones to deploy NGFWs to"
  default = ["us-central1-a", "us-central1-b"]
}

# > gcloud compute images list --project paloaltonetworksgcp-public --no-standard-images
variable "ngfw_image_name" {
  description = "Disk Base Image Name for VM-series Instances"
  default = "vmseries-flex-bundle1-1028"
}

variable "ngfw_image_project" {
  description = "Disk Base Image Project for VM-series Instances"
  default = "paloaltonetworksgcp-public"
}

variable "management_external" {
  description = "Allowed External IP Blocks for Management Traffic"
  default = [
    "1.1.1.1/32"
  ]
}

variable "management_internal" {
  description = "Allowed Internal IP Blocks for Management Traffic"
  default = [
    "10.0.0.0/8"
  ]
}