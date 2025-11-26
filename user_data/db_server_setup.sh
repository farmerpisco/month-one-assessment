#!/bin/bash

# Update and Upgrade system packages
sudo yum update -y
sudo yum upgrade -y

# Install Apache
sudo yum install httpd -y
sudo systemctl enable httpd
sudo systemctl start httpd

# Install PostgreSQL 15 via amazon-linux-extras
sudo amazon-linux-extras install postgresql15 -y

# Install PostgreSQL server + contrib
sudo yum install -y postgresql postgresql-server postgresql-contrib

# Initialize PostgreSQL database
sudo postgresql-setup initdb

# Enable and start PostgreSQL
sudo systemctl enable postgresql
sudo systemctl start postgresql

# Wait a few seconds for PostgreSQL to fully start
sleep 5

# Variables (you can parameterize these)
DB_NAME="techcorpdb"
DB_USER="techcorpuser"
DB_PASSWORD="Techcorp123"

# Create DB, user, and grant privileges
sudo -u postgres psql <<EOF
CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';
CREATE DATABASE $DB_NAME OWNER $DB_USER;
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
EOF

# ----- Allow remote connections -----

PGDATA="/var/lib/pgsql/data"
PG_HBA="$PGDATA/pg_hba.conf"
POSTGRES_CONF="$PGDATA/postgresql.conf"

# Listen on all interfaces
sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" $POSTGRES_CONF

# Allow external access (adjust CIDR to match your VPC)
echo "host    all             all             10.0.0.0/16               md5" | sudo tee -a $PG_HBA

# Restart PostgreSQL to apply changes
sudo systemctl restart postgresql