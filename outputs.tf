output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = aws_lb.lb_tf.dns_name
}

output "vpc-id" {
  description = "The ID of the VPC"
  value       = aws_vpc.tf_vpc.id
}

output "Bastion_public_ip" {
  description = "The public ip of the bastion host server"
  value       = aws_eip.bastion_eip.public_ip
}