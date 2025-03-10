data "vsphere_datacenter" "datacenter" {
  name = "localhost.localdomain"
}


data "vsphere_datastore" "datastore" {
  name          = "datastore1"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}


data "vsphere_host" "host" {
  name          = "localhost.localdomain" # Имя хоста, как в ESXi Web UI
  datacenter_id = data.vsphere_datacenter.datacenter.id
}


data "vsphere_resource_pool" "pool" {
  name          = "Resources"
  datacenter_id = data.vsphere_datacenter.datacenter.id  # Здесь была ошибка
}


data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_ovf_vm_template" "ovfRemote" {
  name              = "srv-01"
  disk_provisioning = "thin"
  datastore_id     =  data.vsphere_datastore.datastore.id
  remote_ovf_url    = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.ova"
  resource_pool_id  = data.vsphere_resource_pool.pool.id
  host_system_id    = data.vsphere_host.host.id
  ovf_network_map   = {
    "VM Network" : data.vsphere_network.network.id
  }
}


resource "vsphere_virtual_machine" "vm_remote_ova" {
  name                 = "srv-01"
  datacenter_id        = data.vsphere_datacenter.datacenter.id
  datastore_id         = data.vsphere_datastore.datastore.id
  host_system_id       = data.vsphere_host.host.id
  resource_pool_id     = data.vsphere_resource_pool.pool.id
  num_cpus             = var.num_cpus
  num_cores_per_socket = var.num_cores_per_socket
  memory               = var.memory
  guest_id             = data.vsphere_ovf_vm_template.ovfRemote.guest_id
  firmware             = data.vsphere_ovf_vm_template.ovfRemote.firmware
  scsi_type            = data.vsphere_ovf_vm_template.ovfRemote.scsi_type
  wait_for_guest_net_timeout = 0
  wait_for_guest_ip_timeout  = 0

  disk {
    label = "disk0"
    size  = 20
  }

  extra_config = {
    "guestinfo.userdata"          = base64encode(file("./cloud-init/srv-01.yaml"))
    "guestinfo.userdata.encoding" = "base64"
  }


  network_interface {
    network_id = data.vsphere_network.network.id
  }

  ovf_deploy {
    allow_unverified_ssl_cert = true
    remote_ovf_url            = data.vsphere_ovf_vm_template.ovfRemote.remote_ovf_url
    disk_provisioning         = data.vsphere_ovf_vm_template.ovfRemote.disk_provisioning
    ovf_network_map           = data.vsphere_ovf_vm_template.ovfRemote.ovf_network_map
  }
}
