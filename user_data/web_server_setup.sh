#!/bin/bash

# Update and Upgrade system packages
yum update -y
yum upgrade -y

# Install Apache
yum install httpd -y

# Wait for network to be fully ready
sleep 5

# Fetch metadata token with retries
for i in {1..5}; do
    TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" \
        -H "X-aws-ec2-metadata-token-ttl-seconds: 21600" -s --connect-timeout 3)
    if [ -n "$TOKEN" ]; then
        break
    fi
    sleep 2
done

# Fetch metadata with token
HOSTNAME=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s --connect-timeout 3 \
    http://169.254.169.254/latest/meta-data/hostname)
PRIVATE_IP=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s --connect-timeout 3 \
    http://169.254.169.254/latest/meta-data/local-ipv4)

# Set defaults if empty
HOSTNAME=${HOSTNAME:-"Unknown"}
PRIVATE_IP=${PRIVATE_IP:-"Unknown"}

if [ -z "$PUBLIC_IP" ]; then
  PUBLIC_IP="No Public IP (Private Subnet)"
fi

# Create HTML page
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Altschool Assessment</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      display: flex;
      justify-content: center;
      align-items: center;
      height: 100vh;
      margin: 0;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
    }
    .container {
      text-align: center;
      padding: 2rem;
      background: rgba(255, 255, 255, 0.1);
      border-radius: 10px;
      backdrop-filter: blur(10px);
    }
    h1 { margin-bottom: 1rem; }
    .timestamp { font-size: 0.9em; opacity: 0.8; }
  </style>
</head>
<body>
  <div class="container">
    <h1>Welcome to my Altschool Third Semester Month 1 Assessment - Paul Adegoke</h1>
    <p>Provisioning resources on AWS using Terraform</p>
    <p>Below is the address of the server you are interacting with now</p>
    <p><b>Instance Hostname:</b> $HOSTNAME</p>
    <p><b>Private IP:</b> $PRIVATE_IP</p>
  </div>
</body>
</html>
EOF

systemctl restart httpd
systemctl enable httpd
