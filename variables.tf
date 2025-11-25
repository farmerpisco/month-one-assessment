variable "region" {
  description = "The aws region where our resources will be depolyed"
  type        = string
  default     = "eu-west-2"
}

variable "instance_type" {
  description = "The type of EC2 instance to deploy"
  type        = string
  default     = "t3.micro"
}

variable "db_instance_type" {
  description = "The type of EC2 instance to deploy"
  type        = string
  default     = "t3.small"
}

variable "ip_address" {
  description = "The IP address that will have inbound access to the bastion host"
  type        = string
  default     = "102.89.76.176/32"
}

variable "key_pair_name" {
  description = "The name of the keypair for bastion host ssh inbound"
  type        = string
  default     = "AltSchoolDemo"
}