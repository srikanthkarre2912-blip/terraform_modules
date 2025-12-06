output "asg_name" {
  value = aws_autoscaling_group.asg.name
}

# Instance IDs currently in the ASG
output "instance_ids" {
  value = data.aws_instances.asg_instances.ids
}
