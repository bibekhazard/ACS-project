terraform {
  backend "s3" {
    bucket         = "winternbb-acs730-svashisht5" # Replace with your bucket name
    key            = "assg1/prod/instances/terraform.tfstate" # Unique key for prod/instances state
    region         = "us-east-1" # Or your desired region
    encrypt        = true
  }
}

data "terraform_remote_state" "network" { # Data source for prod/network state (already present)
  backend = "s3"
  config = {
    bucket         = "winternbb-acs730-svashisht5" # Replace with your bucket name
    key            = "assg1/prod/network/terraform.tfstate" # Path to prod/network's state file
    region         = "us-east-1" # Or your region
    encrypt        = true
  }
}

data "terraform_remote_state" "dev_network" {
  backend = "s3"
  config = {
    bucket         = "winternbb-acs730-svashisht5" # Replace with your bucket name
    key            = "assg1/dev/network/terraform.tfstate" # Path to dev/network's state file
    region         = "us-east-1" # Or your region
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

resource "aws_security_group" "prod_vm_sg" {
  name        = "${var.prefix}-vm-sg"
  description = "Allow SSH inbound from Nonprod VPC (after peering) or Bastion"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id # Use vpc_id from prod/network state

  # Ingress rule for SSH from Nonprod VPC CIDR (to be configured after peering)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [data.terraform_remote_state.dev_network.outputs.vpc_cidr] # Get vpc_cidr from dev/network state
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.default_tags, { Name = "${var.prefix}-vm-sg" })
}


resource "aws_instance" "prod_vm" {
  count         = 2
  ami           = data.aws_ami.amazon_linux_2.id
  instance_type = "t2.micro"
  subnet_id     = data.terraform_remote_state.network.outputs.private_subnet_ids[count.index] # Use private_subnet_ids from prod/network state
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.prod_vm_sg.id]

  tags = merge(var.default_tags, { Name = "${var.prefix}-vm-${count.index + 5}" }) # VM5 and VM6 names
}