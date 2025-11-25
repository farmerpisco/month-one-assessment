#!/bin/bash

# Update and Upgrade system packages
yum update -y
yum upgrade -y

# Install Apache
yum install httpd -y
systemctl enable httpd
systemctl restart httpd

# Install postgres
yum install -y postgresql postgresql-contrib
systemctl enable postgresql
systemctl restart postgresql

