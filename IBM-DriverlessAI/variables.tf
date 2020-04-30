variable "basename" {
    description = "Denotes the name of the VPC to deploy into. Resources associated will be prepended with this name."
    default = "dai"
}

variable "vpc_region" {
  description = "Target region to create this instance"
  default = "us-south"
}

variable "vpc_zone" {
  description = "Target availbility zone to create this instance"
  default = "us-south-3"
}

variable "compute_profile" {
  description = "VM profile to provision"
  default = "gp2-24x224x2"
}

variable "storage_profile" {
    description = "Set the storage profile"
    default = "10iops-tier"
}

variable "storage_capacity" {
    description = "Storage capacity size to create"
    default = "200"
}
