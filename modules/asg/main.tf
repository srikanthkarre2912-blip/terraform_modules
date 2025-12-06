# ----------------------------------------------------------
# IAM Role + Instance Profile for SSM
# ----------------------------------------------------------

resource "aws_iam_role" "instance_role" {
  name = "ec2-ssm-role-${substr(join("", var.subnets), 0, 8)}"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags = var.tags
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.instance_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "instance_profile" {
  name = "ip-${substr(join("", var.subnets),0,8)}"
  role = aws_iam_role.instance_role.name
}

# ----------------------------------------------------------
# AMI - Amazon Linux 2
# ----------------------------------------------------------

data "aws_ami" "amzn2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# ----------------------------------------------------------
# Launch Template with User Data
# ----------------------------------------------------------

resource "aws_launch_template" "lt" {
  name_prefix   = "lt-httpd-${substr(join("", var.subnets),0,8)}"
  image_id      = data.aws_ami.amzn2.id
  instance_type = "t3.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }

  network_interfaces {
    security_groups = [var.instance_sg_id]
  }

  user_data = base64encode(join("\n", [
    "#!/bin/bash -xe",
    "yum update -y",
    "yum install -y httpd",
    "systemctl enable httpd",
    "cat > /var/www/html/index.html <<'HTML'",
    "<html><body><h1>Hello World from EC2 (ASG)</h1></body></html>",
    "HTML",
    "systemctl start httpd"
  ]))

  lifecycle {
    create_before_destroy = true
  }
}

# ----------------------------------------------------------
# Auto Scaling Group
# ----------------------------------------------------------

resource "aws_autoscaling_group" "asg" {
  name                      = "asg-httpd-${substr(join("", var.subnets),0,8)}"
  desired_capacity          = var.desired_capacity
  min_size                  = var.min_size
  max_size                  = var.max_size
  vpc_zone_identifier       = var.subnets
  health_check_type         = "ELB"
  health_check_grace_period = 120

  launch_template {
    id      = aws_launch_template.lt.id
    version = "$Latest"
  }

  # Conditional ALB Target Group attachment
  target_group_arns = length(var.target_group_arns) > 0 ? var.target_group_arns : null

  tag {
    key                 = "Name"
    value               = "httpd-asg-instance"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}

# ----------------------------------------------------------
# INSTANCE DISCOVERY (works on all AWS provider versions)
# ----------------------------------------------------------

data "aws_instances" "asg_instances" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [aws_autoscaling_group.asg.name]
  }
}
