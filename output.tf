output "public_ip" {
  value = aws_launch_template.asg_lc
}

output "instance_size" {
  value = aws_launch_template.asg_lc
}

output "instance_id" {
  value = aws_launch_template.asg_lc
}

output "instance_ami" {
  value = aws_launch_template.asg_lc
}

output "vpc_id" {
  value = aws_vpc.asg_vpc
}

output "auto_scaler" {
  value = aws_autoscaling_group.asg
}
