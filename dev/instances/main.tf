terraform {
  backend "s3" {
    bucket         = "winternbb-acs730-svashisht5" # Replace with your bucket name
    key            = "assg1/dev/instances/terraform.tfstate" # Unique key for dev/instances state
    region         = "us-east-1" # Or your desired region
    encrypt        = true
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket         = "winternbb-acs730-svashisht5" # Replace with your bucket name
    key            = "assg1/dev/network/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}

data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "${var.prefix}-bastion-sg"
  description = "Allow SSH inbound for Bastion Host"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id # Use vpc_id from remote state

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Consider restricting to your IP for security
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.default_tags, { Name = "${var.prefix}-bastion-sg" })
}

resource "aws_security_group" "web_server_sg" {
  name        = "${var.prefix}-web-server-sg"
  description = "Allow HTTP inbound for Web Servers and SSH from Bastion"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id # Use vpc_id from remote state

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # ALB SG will be added later
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups = [aws_security_group.bastion_sg.id] # SSH from Bastion
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.default_tags, { Name = "${var.prefix}-web-server-sg" })
}

resource "aws_security_group" "db_server_sg" {
  name        = "${var.prefix}-db-server-sg"
  description = "Allow Database port from Web Servers and SSH from Bastion"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id # Use vpc_id from remote state

  ingress {
    from_port        = 5432 # Example PostgreSQL port
    to_port          = 5432
    protocol         = "tcp"
    security_groups = [aws_security_group.web_server_sg.id] # DB access from Web Servers
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups = [aws_security_group.bastion_sg.id] # SSH from Bastion
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.default_tags, { Name = "${var.prefix}-db-server-sg" })
}


resource "aws_instance" "bastion_host" {
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  subnet_id     = data.terraform_remote_state.network.outputs.public_subnet_ids[0] # Use public_subnet_ids from remote state
  key_name      = var.key_name # Make sure you have this key
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = merge(var.default_tags, { Name = "${var.prefix}-bastion" })
}


resource "aws_instance" "web_server" {
  count         = 2
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  subnet_id     = data.terraform_remote_state.network.outputs.public_subnet_ids[count.index] # Use public_subnet_ids from remote state
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.web_server_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Web Server from ${var.environment} environment - Instance Private IP: $(curl http://169.254.169.254/latest/meta-data/local-ipv4) - Your Name: ${var.your_name}</h1>" > /var/www/html/index.html
              EOF

  tags = merge(var.default_tags, { Name = "${var.prefix}-web-server-${count.index + 1}" })
}

resource "aws_instance" "db_server" {
  count         = 2 # VM3 and VM4
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  subnet_id     = data.terraform_remote_state.network.outputs.private_subnet_ids[count.index] # Use private_subnet_ids from remote state
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.db_server_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y postgresql-server # Example DB - PostgreSQL
              postgresql-setup initdb
              systemctl start postgresql
              systemctl enable postgresql

              # Allow remote connections to PostgreSQL - AUTOMATED CONFIGURATION
              PGDATA=$(sudo -u postgres psql -t -c "SHOW data_directory") # Get PGDATA directory
              echo "Updating postgresql.conf to listen on all interfaces..."
              sudo sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" $PGDATA/postgresql.conf # Modify listen_addresses

              echo "Updating pg_hba.conf to allow connections from all IPs (0.0.0.0/0)"
              sudo sed -i "\$ a host all all 0.0.0.0/0 trust" $PGDATA/pg_hba.conf

              echo "Restarting postgresql service to apply changes..."
              sudo systemctl restart postgresql
              EOF

  tags = merge(var.default_tags, { Name = "${var.prefix}-db-server-${count.index + 3}" }) # VM3 and VM4 names
}