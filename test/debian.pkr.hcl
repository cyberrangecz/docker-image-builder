packer {
  required_plugins {
    qemu = {
      source  = "github.com/hashicorp/qemu"
      version = "~> 1"
    }
    vagrant = {
      source  = "github.com/hashicorp/vagrant"
      version = "~> 1"
    }
    virtualbox = {
      source  = "github.com/hashicorp/virtualbox"
      version = "~> 1"
    }
  }
}

variable "boot_wait" {
  type    = string
  default = "5s"
}

variable "cpus" {
  type    = string
  default = "4"
}

variable "disk_size" {
  type    = string
  default = "16384"
}

variable "headless" {
  type    = string
  default = "true"
}

variable "http_directory" {
  type    = string
  default = "http"
}

variable "http_port_max" {
  type    = string
  default = "10089"
}

variable "http_port_min" {
  type    = string
  default = "10082"
}

variable "iso_checksum" {
  type    = string
  default = "30809f90e18cc501e88e615b45509fd128c2cf9a7f52742a528001898fd35a09"
}

variable "iso_url" {
  type    = string
  default = "https://cdimage.debian.org/mirror/cdimage/archive/10.8.0/amd64/iso-cd/debian-10.8.0-amd64-xfce-CD-1.iso"
}

variable "memory_size" {
  type    = string
  default = "4096"
}

variable "shutdown_command" {
  type    = string
  default = "shutdown -P now"
}

variable "ssh_password" {
  type    = string
  default = "toor"
}

variable "ssh_port" {
  type    = string
  default = "22"
}

variable "ssh_username" {
  type    = string
  default = "root"
}

variable "ssh_wait_timeout" {
  type    = string
  default = "90m"
}

variable "vm_name" {
  type    = string
  default = "debian"
}

variable "vnc_vrdp_bind_address" {
  type    = string
  default = "127.0.0.1"
}

variable "vnc_vrdp_port" {
  type    = string
  default = "5900"
}

source "qemu" "qemu" {
  boot_command        = ["<esc><wait>", "install", " auto", " priority=critical", " locale=en_US.UTF-8", " keyboard-configuration/xkb-keymap=us", " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg", "<enter>"]
  boot_key_interval   = "10ms"
  boot_wait           = "${var.boot_wait}"
  disk_interface      = "virtio-scsi"
  disk_size           = "${var.disk_size}"
  format              = "raw"
  headless            = "${var.headless}"
  http_directory      = "${var.http_directory}"
  http_port_max       = "${var.http_port_max}"
  http_port_min       = "${var.http_port_min}"
  iso_checksum        = "${var.iso_checksum}"
  iso_url             = "${var.iso_url}"
  net_device          = "virtio-net"
  output_directory    = "target-qemu"
  qemuargs            = [["-m", "${var.memory_size}m"], ["-smp", "cpus=${var.cpus},maxcpus=16,cores=4"]]
  shutdown_command    = "${var.shutdown_command}"
  ssh_password        = "${var.ssh_password}"
  ssh_port            = "${var.ssh_port}"
  ssh_username        = "${var.ssh_username}"
  ssh_wait_timeout    = "${var.ssh_wait_timeout}"
  use_default_display = "${var.headless}"
  vm_name             = "${var.vm_name}"
  vnc_bind_address    = "${var.vnc_vrdp_bind_address}"
  vnc_port_max        = "${var.vnc_vrdp_port}"
  vnc_port_min        = "${var.vnc_vrdp_port}"
}

source "virtualbox-iso" "vbox" {
  boot_command      = ["<esc><wait>", "install", " auto", " priority=critical", " locale=en_US.UTF-8", " keyboard-configuration/xkb-keymap=us", " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg", "<enter>"]
  boot_wait         = "${var.boot_wait}"
  disk_size         = "${var.disk_size}"
  guest_os_type     = "Debian_64"
  headless          = "${var.headless}"
  http_directory    = "${var.http_directory}"
  http_port_max     = "${var.http_port_max}"
  http_port_min     = "${var.http_port_min}"
  iso_checksum      = "${var.iso_checksum}"
  iso_url           = "${var.iso_url}"
  shutdown_command  = "echo 'vagrant' | ${var.shutdown_command}"
  ssh_password      = "${var.ssh_password}"
  ssh_port          = "${var.ssh_port}"
  ssh_username      = "${var.ssh_username}"
  ssh_wait_timeout  = "${var.ssh_wait_timeout}"
  vboxmanage        = [["modifyvm", "{{ .Name }}", "--memory", "${var.memory_size}"], ["modifyvm", "{{ .Name }}", "--cpus", "${var.cpus}"]]
  vm_name           = "${var.vm_name}"
  vrdp_bind_address = "${var.vnc_vrdp_bind_address}"
  vrdp_port_max     = "${var.vnc_vrdp_port}"
  vrdp_port_min     = "${var.vnc_vrdp_port}"
}

build {
  sources = ["source.qemu.qemu", "source.virtualbox-iso.vbox"]

  provisioner "shell" {
    only    = ["virtualbox-iso.vbox"]
    scripts = ["scripts/addVagrantUser.sh", "scripts/guestAdditions.sh"]
  }

  post-processor "vagrant" {
    only   = ["virtualbox-iso.vbox"]
    output = "target-vbox/debian.box"
  }
}
