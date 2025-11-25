terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.20.0"
    }
  }
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_vpc" "tf_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "Techcorp-vpc"
  }
}

resource "aws_subnet" "tf_subnet_public1" {
  vpc_id     = aws_vpc.tf_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "Techcorp-Public-Subnet-1"
  }
}

resource "aws_subnet" "tf_subnet_public2" {
  vpc_id     = aws_vpc.tf_vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "Techcorp-Public-Subnet-2"
  }
}

resource "aws_subnet" "tf_subnet_private1" {
  vpc_id     = aws_vpc.tf_vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "eu-west-2a"

  tags = {
    Name = "Techcorp-private-subnet-1"
  }
}

resource "aws_subnet" "tf_subnet_private2" {
  vpc_id     = aws_vpc.tf_vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "eu-west-2b"

  tags = {
    Name = "Techcorp-private-subnet-2"
  }
}

resource "aws_internet_gateway" "tf_gw" {
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "Techcorp-Internet-Gateway"
  }
}

resource "aws_eip" "nat" {
  tags = {
    Name = "Techcorp-NAT-EIP"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.tf_subnet_public1.id

  tags = {
    Name = "Techcorp-NAT-GW"
  }

  depends_on = [aws_internet_gateway.tf_gw]
}

resource "aws_route_table" "tf_rt" {
  vpc_id = aws_vpc.tf_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf_gw.id
  }

  tags = {
    Name = "Techcorp-Public-RT"
  }
}

resource "aws_route_table_association" "public_rta1" {
  subnet_id      = aws_subnet.tf_subnet_public1.id
  route_table_id = aws_route_table.tf_rt.id
}

resource "aws_route_table_association" "public_rta2" {
  subnet_id      = aws_subnet.tf_subnet_public2.id
  route_table_id = aws_route_table.tf_rt.id
}

resource "aws_route_table" "tf_private_rt" {
  vpc_id = aws_vpc.tf_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "Techcorp-Private-RT"
  }
}

resource "aws_route_table_association" "private_rta1" {
  subnet_id      = aws_subnet.tf_subnet_private1.id
  route_table_id = aws_route_table.tf_private_rt.id
}

resource "aws_route_table_association" "private_rta2" {
  subnet_id      = aws_subnet.tf_subnet_private2.id
  route_table_id = aws_route_table.tf_private_rt.id
}

resource "aws_security_group" "wsg" {
  name   = "web-sg"
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "Web-SG"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTP from anywhere"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS from anywhere"
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bsg.id]
    description     = "Allow SSH from Bastion SG"
  }

  ingress {
  from_port = 80
  to_port   = 80
  protocol  = "tcp"
  security_groups = [aws_security_group.alb_sg.id]
}


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "dbsg" {
  name   = "database-sg"
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "Database-SG"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "db_mysql_from_web" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.wsg.id
  security_group_id        = aws_security_group.dbsg.id
  description              = "Allow MySQL from Web SG"
}

resource "aws_security_group_rule" "db_ssh_from_bastion" {
  type                     = "ingress"
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bsg.id
  security_group_id        = aws_security_group.dbsg.id
  description              = "Allow SSH from Bastion SG"
}

resource "aws_security_group" "bsg" {
  name   = "bastion-sg"
  vpc_id = aws_vpc.tf_vpc.id

  tags = {
    Name = "Bastion-SG"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["102.89.76.176/32"]
    description = "Allow SSH from my IP"
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "bastion_host" {
  ami             = "ami-0a0ff88d0f3f85a14"
  instance_type   = "t3.micro"
  subnet_id       = aws_subnet.tf_subnet_public1.id
  security_groups = [aws_security_group.bsg.id]
  

  tags = {
    Name = "Bastion-host"
  }
}

resource "aws_eip" "bastion_eip" {
  instance = aws_instance.bastion_host.id
}

resource "aws_instance" "web_server1" {
  ami             = "ami-0a0ff88d0f3f85a14"
  instance_type   = "t3.micro"
  subnet_id       = aws_subnet.tf_subnet_private1.id
  security_groups = [aws_security_group.wsg.id]

  user_data = file("${path.module}/web_server_setup.sh")

  tags = {
    Name = "Web-server1"
  }
}

resource "aws_instance" "web_server2" {
  ami             = "ami-0a0ff88d0f3f85a14"
  instance_type   = "t3.micro"
  subnet_id       = aws_subnet.tf_subnet_private2.id
  security_groups = [aws_security_group.wsg.id]

  user_data = file("${path.module}/web_server_setup.sh")

  tags = {
    Name = "Web-server2"
  }
}

resource "aws_instance" "db_server" {
  ami             = "ami-0a0ff88d0f3f85a14"
  instance_type   = "t3.small"
  subnet_id       = aws_subnet.tf_subnet_private1.id
  security_groups = [aws_security_group.dbsg.id]

  user_data = file("${path.module}/db_server_setup.sh")

  tags = {
    Name = "DB-server"
  }
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-security-group"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.tf_vpc.id

  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "Techcorp-alb-SG"
  }
}

resource "aws_lb" "lb_tf" {
  name               = "Techcorp-LB"
  load_balancer_type = "application"
  subnets            = [
    aws_subnet.tf_subnet_public1.id,
    aws_subnet.tf_subnet_public2.id
  ]
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_lb_target_group" "lb_tg" {
  name     = "Techcorp-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.tf_vpc.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
    interval            = 30
  }
}

resource "aws_lb_target_group_attachment" "tg_at" {
  target_group_arn = aws_lb_target_group.lb_tg.arn
  target_id        = aws_instance.web_server1.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "tg_at2" {
  target_group_arn = aws_lb_target_group.lb_tg.arn
  target_id        = aws_instance.web_server2.id
  port             = 80
}

resource "aws_lb_listener" "lb_http" {
  load_balancer_arn = aws_lb.lb_tf.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_tg.arn
  }
}