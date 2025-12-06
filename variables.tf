variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "env" {
  description = "Environment name used in tags"
  type        = string
  default     = "prod"
}

variable "attach_to_alb" {
  description = "When false, ASG will NOT be attached to the ALB/target group. Resources remain defined but disassociated."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Common tags for resources"
  type        = map(string)
  default     = {
    Project = "demo-httpd-asg-alb"
  }
}
