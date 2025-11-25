# Deployment a Web Application Using Terraform

This project provisions a web application that ensures:

- **High availability across multiple availability zones**
- **Secure network isolation with public and private subnets**
- **Load balancing for web traffic**
- **Bastion host for secure administrative access**
- **Scalable architecture that can grow with the business**

---

## Prerequisites

Before deploying the infrastructure, ensure you have the following installed on your system:

### 1. **Terraform**
Download and install from:  
https://developer.hashicorp.com/terraform/downloads

Verify installation:
```bash
terraform -v
```
### 2. **AWS CLI**
Install the AWS CLI:
https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

Verify installation:
```bash
aws --version
```
Configure AWS CLI
```bash
aws configure
```
You must provide:
- **AWS Access Key ID**
- **AWS Secret Access Key**
- **Default region (e.g., us-east-1)**
- **Output format (optional)**

### 3. **SSH KEY**

## Deployment Instructions
Follow the steps below to deploy the infrastructure

### 1. **Clone the repository**
```bash
git clone https://github.com/farmerpisco/month-one-assessment.git
cd month-one-assessment
```

### 2. **Initialize Terraform**
```bash
terraform init
```

### 3. **Preview the Infrastructure Plan**
```bash
terraform plan
```
This will show the resources that will be created

### 4. **Deploy the infrastructure**
```bash
terraform apply
```
You will be prompted to input "yes" to allow terraform provision the resources
Terraform will provision the following:
- Virtual Private Cloud (VPC), Public and Private Subnets, Route Tables
- Internet gateway, and NAT gateway
- Security Groups
- EC2 Instances for Web servers, Database server, and Bastion host server
- An Application Load Balancer
- User data configuration

### 5. **Retrieve Output Values**
You will see the following outputs after terraform is done with the infrastructure deployments:
- VPC ID
- ALB DNS name
- Bastion host elastic public ip

### 6. **SSH into the Bastion Host**
You can ssh into the bastion host using your key pair name and bastion host elastic IP
```bash
ssh -i yourkeyname.pem ec2-user@bastion_public_ip
```

### 7. **Infrastructure CLeanup** 
You should destory all the infrastructure when you are done to avoid unwanted costs
```bash
terraform destroy
```
You will be prompted to input "yes" to allow terraform destroy all the resources
Terraform will destroy the following:
- Virtual Private Cloud (VPC), Public and Private Subnets, Route Tables
- Internet gateway, and NAT gateway
- Security Groups
- EC2 Instances for Web servers, Database server, and Bastion host server
- An Application Load Balancer
- User data configuration

