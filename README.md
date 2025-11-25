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
git clone <your-repo-url>
cd <project-folder>
