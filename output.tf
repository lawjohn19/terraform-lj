output "public_ip" {
  value = aws_instance.jenkins-web.public_ip
}

output "instance_size" {
  value = aws_instance.jenkins-web.instance_type
}

output "instance_id" {
  value = aws_instance.jenkins-web.id
}

output "instance_ami" {
  value = aws_instance.jenkins-web.ami
}

output "vpc_id" {
  value = aws_vpc.new_vpc1.id
}
