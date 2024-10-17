variable "project" {
  type    = string
  default = "myvpc"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "private_subnets" {
  type    = list(string)
  default =  ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnets" {
  type    = list(string)
  default = [ "10.0.4.0/24" ]
}

variable "database_subnets" {
  type    = list(string)
  default =  ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
}

