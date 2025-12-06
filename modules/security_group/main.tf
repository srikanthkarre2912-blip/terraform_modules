resource "aws_security_group" "alb_sg" {
  name        = "sg-alb-${substr(var.vpc_id,0,8)}"
  description = "ALB security group - allow HTTP from anywhere"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}

resource "aws_security_group" "ec2_sg" {
  name        = "sg-ec2-${substr(var.vpc_id,0,8)}"
  description = "EC2 security group - allow HTTP from ALB only"
  vpc_id      = var.vpc_id

  ingress {
    description      = "HTTP from ALB"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    security_groups  = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = var.tags
}
