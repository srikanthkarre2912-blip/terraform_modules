# Get default VPC and subnets
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security groups module creates both ALB SG and EC2 SG
module "sgs" {
  source = "./modules/security_group"

  vpc_id = data.aws_vpc.default.id
  
  tags = merge(
    var.tags,
    {
      Environment = var.env
    }
  )
    
}

# ALB module
module "alb" {
  source = "./modules/alb"

  vpc_id     = data.aws_vpc.default.id
  subnets    = data.aws_subnets.default.ids
  alb_sg_id  = module.sgs.alb_sg_id
  target_port = 80

  tags = merge(var.tags, { Environment = var.env })
}

# ASG module
module "asg" {
  source = "./modules/asg"

  subnets = data.aws_subnets.default.ids
  instance_sg_id = module.sgs.ec2_sg_id

  # if attach_to_alb is true, pass target group arn; else pass empty list
  target_group_arns = var.attach_to_alb ? [module.alb.target_group_arn] : []

  desired_capacity = 2
  min_size         = 2
  max_size         = 4

  tags = merge(var.tags, { Environment = var.env })
}
