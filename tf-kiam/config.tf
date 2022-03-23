provider "aws" {
  region = "us-east-1"
}

variable "kiam_role_domain" {
  type    = string
  default = ".tce"
}

variable "controlplane_node_role_name" {
  type    = string
  default = "control-plane.tkg.cloud.vmware.com"
}
