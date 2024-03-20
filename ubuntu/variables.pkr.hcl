packer {
  required_version = ">= 1.7.0"
  required_plugins {
    qemu = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}


qemu_arch = {
  "amd64" = "x86_64"
  "arm64" = "aarch64"
}

uefi_imp = {
  "amd64" = "OVMF"
  "arm64" = "AAVMF"
}

qemu_machine = {
  "amd64" = "ubuntu,accel=kvm"
  "arm64" = "virt"
}

qemu_cpu = {
  "amd64" = "host"
  "arm64" = "cortex-a57"
}

variable "headless" {
  type        = bool
  default     = true
  description = "Whether VNC viewer should not be launched."
}

variable "http_directory" {
  type    = string
  default = "http"
}

variable "http_proxy" {
  type    = string
  default = "${env("http_proxy")}"
}

variable "https_proxy" {
  type    = string
  default = "${env("https_proxy")}"
}

variable "no_proxy" {
  type    = string
  default = "${env("no_proxy")}"
}

variable "ssh_password" {
  type    = string
  default = "ubuntu"
}

variable "ssh_username" {
  type    = string
  default = "root"
}

variable "ssh_ubuntu_password" {
  type    = string
  default = "ubuntu"
}

variable "ubuntu_series" {
  type        = string
  default     = "jammy"
  description = "The codename of the Ubuntu series to build."
}

variable "architecture" {
  type        = string
  default     = "amd64"
  description = "The architecture to build the image for (amd64 or arm64)"
}

variable "timeout" {
  type        = string
  default     = "1h"
  description = "Timeout for building the image"
}
