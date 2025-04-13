#!/bin/bash
exec > /var/log/user_data_db.log 2>&1

# Install dependencies
sudo yum update -y
sudo yum install -y libaio ncurses-compat-libs

# Create MySQL user and group
sudo groupadd mysql
sudo useradd -r -g mysql -s /bin/false mysql

# Download MySQL 8.0 (adjust version as needed)
MYSQL_VERSION="8.0.37"
wget https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-${MYSQL_VERSION}-linux-glibc2.12-x86_64.tar.xz
tar xvf mysql-${MYSQL_VERSION}-linux-glibc2.12-x86_64.tar.xz
sudo mv mysql-${MYSQL_VERSION}-linux-glibc2.12-x86_64 /usr/local/mysql

# Create necessary directories
sudo mkdir -p /var/lib/mysql
sudo mkdir -p /var/run/mysql

# Set permissions
sudo chown -R mysql:mysql /usr/local/mysql
sudo chown -R mysql:mysql /var/lib/mysql
sudo chown -R mysql:mysql /var/run/mysql

# Initialize MySQL
cd /usr/local/mysql
sudo bin/mysqld --initialize --user=mysql --basedir=/usr/local/mysql --datadir=/var/lib/mysql

# Get temporary root password
temp_password=$(sudo grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')

# Create systemd service
sudo tee /etc/systemd/system/mysqld.service <<EOF
[Unit]
Description=MySQL Server
After=network.target

[Service]
User=mysql
Group=mysql
ExecStart=/usr/local/mysql/bin/mysqld --basedir=/usr/local/mysql --datadir=/var/lib/mysql
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start MySQL
sudo systemctl daemon-reload
sudo systemctl enable mysqld
sudo systemctl start mysqld

# Secure installation and create DB/user
sleep 10  # Wait for MySQL to start
sudo /usr/local/mysql/bin/mysql --connect-expired-password -u root -p"$temp_password" --password-expired <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY 'StrongRootPass123!';
CREATE DATABASE acs730db;
CREATE USER 'acs730user'@'%' IDENTIFIED BY 'DBUserPass123!';
GRANT ALL PRIVILEGES ON acs730db.* TO 'acs730user'@'%';
FLUSH PRIVILEGES;
EOF

# Create symlinks to /usr/local/bin
sudo ln -sf /usr/local/mysql/bin/mysql /usr/local/bin/mysql
sudo ln -sf /usr/local/mysql/bin/mysqldump /usr/local/bin/mysqldump
sudo ln -sf /usr/local/mysql/bin/mysqladmin /usr/local/bin/mysqladmin

# Configure environment
echo 'export PATH=$PATH:/usr/local/mysql/bin' | sudo tee /etc/profile.d/mysql.sh
source /etc/profile.d/mysql.sh

# Allow remote connections
sudo sed -i "s/^bind-address.*/bind-address = 0.0.0.0/" /etc/my.cnf
sudo systemctl restart mysqld

# Firewall rules (if needed)
sudo firewall-cmd --add-port=3306/tcp --permanent
sudo firewall-cmd --reload