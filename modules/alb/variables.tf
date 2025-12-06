variable "vpc_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "alb_sg_id" {
  type = string
}

variable "target_port" {
  type    = number
  default = 80
}

variable "tags" {
  type    = map(string)
  default = {}
}
