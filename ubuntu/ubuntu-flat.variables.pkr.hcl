variable "ubuntu_series" {
  type        = string
  default     = "jammy"
  description = "The codename of the Ubuntu series to build."
}

variable "flat_filename" {
  type        = string
  default     = "custom-ubuntu.tar.gz"
  description = "The filename of the tarball to produce"
}

variable "ubuntu_iso" {
  type        = string
  default     = "ubuntu-22.04.3-live-server-amd64.iso"
  description = "The ISO name to build the image from"
}

variable "architecture" {
  type        = string
  default     = "amd64"
  description = "The architecture to build the image for (amd64 or arm64)"
}

