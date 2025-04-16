data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

locals {
  tags = merge(var.tags, {
    Environment = var.environment
    Group       = var.group_name
    Terraform   = "true"
  })
}

# Security Groups
resource "aws_security_group" "public_web" {
  name        = "${var.group_name}-${var.environment}-PublicWeb-SG"
  description = "Public Web Server Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_access_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { 
    Name = "${var.group_name}-${var.environment}-PublicWeb-SG"
  })
}

resource "aws_security_group" "private_web" {
  name        = "${var.group_name}-${var.environment}-PrivateWeb-SG"
  description = "Private Web Server Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [var.alb_security_group_id]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { 
    Name = "${var.group_name}-${var.environment}-PrivateWeb-SG"
  })
}

resource "aws_security_group" "bastion" {
  name        = "${var.group_name}-${var.environment}-Bastion-SG"
  description = "Bastion Host Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_access_cidr]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.ssh_access_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { 
    Name = "${var.group_name}-${var.environment}-Bastion-SG"
  })
}

resource "aws_security_group" "database" {
  name        = "${var.group_name}-${var.environment}-DB-SG"
  description = "Database Security Group"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [
      aws_security_group.bastion.id,
      aws_security_group.private_web.id
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { 
    Name = "${var.group_name}-${var.environment}-DB-SG"
  })
}

# EC2 Instances
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_ids[1]
  vpc_security_group_ids = [aws_security_group.bastion.id]
  key_name               = var.key_name
  user_data              = file("${path.module}/user_data/webserver.sh")

  tags = merge(local.tags, {
    Name = "${var.group_name}-${var.environment}-Bastion"
    Role = "Bastion"
  })
}

resource "aws_instance" "public_web" {
  count                  = 2
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = element(var.public_subnet_ids, count.index % length(var.public_subnet_ids))
  vpc_security_group_ids = [aws_security_group.public_web.id]
  key_name               = var.key_name
  user_data              = <<-EOF
              #!/bin/bash
              set -x
              yum update -y
              amazon-linux-extras enable python3.8
              yum install -y python3.8 python3-pip
              yum install -y python3-devel gcc
              alternatives --set python /usr/bin/python3.8
              alternatives --set python3 /usr/bin/python3.8
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

              cat <<EOT > /var/www/html/index.html
              <!DOCTYPE html>
              <html>
              <head>
                  <title>ACS730 Group Project</title>
                  <style>
                      body {
                          background-image: url('https://acs-final-project.s3.us-east-1.amazonaws.com/seneca.jpg');
                          background-size: cover;
                          background-repeat: no-repeat;
                          color: white;
                          text-shadow: 2px 2px 4px #000000;
                          font-family: Arial, sans-serif;
                      }
                      .content {
                          background-color: rgba(0, 0, 0, 0.6);
                          padding: 20px;
                          margin: 50px;
                          border-radius: 10px;
                      }
                  </style>
              </head>
              <body>
                  <div class="content">
                      <h1>Hello from ACS730 Group Project</h1>
                      <p>Environment: ${var.environment}</p>
                      <p>Public IP: $PUBLIC_IP</p>
                      <p>Instance Type: ${var.instance_type}</p>
                  </div>
              </body>
              </html>
              EOT
              chmod 644 /var/www/html/index.html
              systemctl restart httpd
              EOF

  tags = merge(local.tags, {
    Name  = "${var.group_name}-${var.environment}-WebServer-${count.index + 1}"
    Role  = "PublicWeb"
    Owner = "acs730"
  })
}

resource "aws_instance" "private_web" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.private_web.id]
  key_name               = var.key_name
  user_data              = file("${path.module}/user_data/webserver.sh")

  tags = merge(local.tags, {
    Name = "${var.group_name}-${var.environment}-Private-Web"
    Role = "PrivateWeb"
  })
}

resource "aws_instance" "database" {
  ami                    = data.aws_ami.latest_amazon_linux.id
  instance_type          = var.db_instance_type
  subnet_id              = var.private_subnet_ids[1]
  vpc_security_group_ids = [aws_security_group.database.id]
  key_name               = var.key_name
  user_data              = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y postgresql-server
              postgresql-setup initdb
              systemctl start postgresql
              systemctl enable postgresql

              PGDATA=$(sudo -u postgres psql -t -c "SHOW data_directory")
              sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" $PGDATA/postgresql.conf
              echo "host all all 0.0.0.0/0 trust" >> $PGDATA/pg_hba.conf
              systemctl restart postgresql
              EOF

  tags = merge(local.tags, {
    Name = "${var.group_name}-${var.environment}-Database"
    Role = "Database"
  })
}
