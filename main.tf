terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc4"
    }
  }
}

provider "proxmox" {
  pm_api_url = "https://192.168.8.133:8006/api2/json"
  pm_api_token_id = "terraform@pam!tf-token"
  pm_api_token_secret = "fad8d5f8-0c9f-45d7-8128-14a9a6ef432d"
  pm_tls_insecure = true
}

resource "proxmox_vm_qemu" "mesin_tempur" {
  count = 1 
  name = "LLM-dev" 
  target_node = "zli" 
  # vmid        = 110
  clone = "debian-12-cloud-template" 

  full_clone = true

  # --- SISTEM ---
  agent = 1
  os_type = "cloud-init"
  cores = 1
  sockets = 1
  cpu = "host"
  memory = 2048
  scsihw = "virtio-scsi-pci"
  
  boot = "order=scsi0;net0"

  # --- DISK 1 ---
  disk {
    slot = "scsi0"
    type = "disk"
    storage = "ssd-0"
    size = "32G"
  }

  # --- DISK 2: CLOUD-INIT ---
  disk {
    slot = "ide2"
    type = "cloudinit"
    storage = "ssd-0"
  }

  # --- DISPLAY ---
  vga {
    type = "std"
  }

  serial {
    id = 0
    type = "socket"
  }

  # --- NETWORK ---
  network {
    model = "virtio"
    bridge = "vmbr0"
  }

  # --- LIFECYCLE ---
  onboot = true
  automatic_reboot = true

  # --- USER & IP ---
  ciuser = "sainz"
  cipassword = "fazli2005"
  ipconfig0 = "ip=192.168.8.80/24,gw=192.168.8.1"
}