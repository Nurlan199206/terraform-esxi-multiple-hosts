terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      version = "2.11.1"
    }
  }
}

provider "vsphere" {
  user                 = "root"
  password             = "galamat2025@"
  vsphere_server       = "192.168.200.17"
  allow_unverified_ssl  = true
  api_timeout          = 10
}


module "srv-01" {
  source = "./vms/srv-01"
}

module "srv-02" {
  source = "./vms/srv-02"
}
