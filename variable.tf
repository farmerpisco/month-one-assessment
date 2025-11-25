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