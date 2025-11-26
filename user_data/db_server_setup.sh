#!/bin/bash

# Update and Upgrade system packages
yum update -y
yum upgrade -y

# Install Apache
yum install httpd -y
systemctl enable httpd
systemctl start httpd

# Install PostgreSQL (Amazon Linux 2 uses PostgreSQL 15 repository)
amazon-linux-extras install postgresql15 -y || true


# Install PostgreSQL server + contrib
yum install -y postgresql15 postgresql15-server postgresql15-contrib

# Initialize PostgreSQL database
/usr/pgsql-15/bin/postgresql-15-setup initdb

# Enable and start PostgreSQL
systemctl enable postgresql-15
systemctl start postgresql-15

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

PGDATA="/var/lib/pgsql/15/data"
PG_HBA="$PGDATA/pg_hba.conf"
POSTGRES_CONF="$PGDATA/postgresql.conf"

# Listen on all interfaces
sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/g" $POSTGRES_CONF

# Allow external access
echo "host    all             all             10.0.0.0/16               md5" >> $PG_HBA

# Restart PostgreSQL to apply changes
systemctl restart postgresql-15

echo "PostgreSQL installed and configured successfully."
echo "Database: $DB_NAME"
echo "User: $DB_USER"





