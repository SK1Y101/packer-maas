locals {
  url_base = {
    "amd64" = "releases.ubuntu.com/${var.ubuntu_series}"
    "arm64" = "cdimage.ubuntu.com/releases/${var.ubuntu_series}/release"
  }
}

source "qemu" "flat" {
  boot_command    = ["<wait>e<wait5>", "<down><wait><down><wait><down><wait2><end><wait5>", "<bs><bs><bs><bs><wait>autoinstall ---<wait><f10>"]
  boot_wait       = "2s"
  cpus            = 2
  disk_size       = "8G"
  format          = "raw"
  headless        = var.headless
  http_directory  = var.http_directory
  iso_checksum    = "file:http://${lookup(local.url_base, var.architecture, "")}/SHA256SUMS"
  iso_target_path = "packer_cache/${var.ubuntu_series}/${var.architecture}.iso"
  iso_url         = "https://${lookup(local.url_base, var.architecture, "")}/${var.ubuntu_iso}-${var.architecture}.iso"
  memory          = 2048
  qemu_binary    = "qemu-system-${lookup(var.qemu_arch, var.architecture, "")}"
  qemuargs = [
    ["-device", "virtio-gpu-pci"],
    ["-machine", "${lookup(var.qemu_machine, var.architecture, "")}"],
    ["-cpu", "${lookup(var.qemu_cpu, var.architecture, "")}"],
    ["-device", "virtio-blk-pci,drive=drive0,bootindex=0"],
    ["-device", "virtio-blk-pci,drive=cdrom0,bootindex=1"],
    ["-device", "virtio-blk-pci,drive=drive1,bootindex=2"],
    ["-drive", "if=pflash,format=raw,readonly=on,file=/usr/share/${lookup(var.uefi_imp, var.architecture, "")}/${lookup(var.uefi_imp, var.architecture, "")}_CODE.fd"],
    ["-drive", "if=pflash,format=raw,id=ovmf_vars,file=${lookup(var.uefi_imp, var.architecture, "")}_VARS.fd"],
    ["-drive", "file=output-flat/packer-flat,if=none,id=drive0,cache=writeback,discard=ignore,format=raw"],
    ["-drive", "file=seeds-flat.iso,format=raw,cache=none,if=none,id=drive1,readonly=on"],
    ["-drive", "file=packer_cache/${var.ubuntu_series}/${var.architecture}.iso,if=none,id=cdrom0,media=cdrom"]
  ]
  shutdown_command       = "sudo -S shutdown -P now"
  ssh_handshake_attempts = 500
  ssh_password           = var.ssh_ubuntu_password
  ssh_timeout            = var.timeout
  ssh_username           = "ubuntu"
  ssh_wait_timeout       = var.timeout
}

build {
  sources = ["source.qemu.flat"]

  provisioner "file" {
    destination = "/tmp/"
    sources = [
      "${path.root}/scripts/curtin-hooks",
      "${path.root}/scripts/install-custom-packages",
      "${path.root}/scripts/setup-bootloader",
      "${path.root}/packages/custom-packages.tar.gz"
    ]
  }

  provisioner "shell" {
    environment_vars  = ["HOME_DIR=/home/ubuntu", "http_proxy=${var.http_proxy}", "https_proxy=${var.https_proxy}", "no_proxy=${var.no_proxy}"]
    execute_command   = "echo 'ubuntu' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    expect_disconnect = true
    scripts           = ["${path.root}/scripts/curtin.sh", "${path.root}/scripts/networking.sh", "${path.root}/scripts/cleanup.sh"]
  }

  post-processor "shell-local" {
    inline = [
      "SOURCE=flat",
      "IMG_FMT=raw",
      "ROOT_PARTITION=2",
      "OUTPUT=${var.flat_filename}",
      "source ../scripts/fuse-nbd",
      "source ../scripts/fuse-tar-root"
    ]
    inline_shebang = "/bin/bash -e"
  }
}
