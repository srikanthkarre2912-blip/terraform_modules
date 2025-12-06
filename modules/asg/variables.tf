variable "subnets" {
  type = list(string)
}

variable "instance_sg_id" {
  type = string
}

variable "target_group_arns" {
  description = "List of target group ARNs to attach to the ASG. When empty, ASG will not register to any TG (disassociation mechanism)."
  type        = list(string)
  default     = []
}

variable "desired_capacity" {
  type    = number
  default = 2
}
variable "min_size" {
  type    = number
  default = 2
}
variable "max_size" {
  type    = number
  default = 4
}

variable "tags" {
  type    = map(string)
  default = {}
}
