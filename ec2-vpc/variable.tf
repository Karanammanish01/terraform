variable "prod_env" {
  default = "prod"
  type = string
}


variable "default_root_volume" {
  default = 10
  type = number
}

variable "default_cidr_block" {
  default = "10.0.0.0/16"
  type = string
}

variable "default_ami_image" {
  default = "ami-0ec10929233384c7f"
  type = string
}

variable "default_instance_type" {
  default = "t2.nano"
  type = string
}

variable "default_region" {
  default = "us-east-1"
  type = string
}