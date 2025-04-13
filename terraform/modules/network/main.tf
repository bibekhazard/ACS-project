data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  tags = merge(var.tags, {
    Environment = var.environment
    Group       = var.group_name
    Terraform   = "true"
  })
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags = merge(local.tags, {
    Name = "${var.group_name}-${var.environment}-VPC"
  })
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = merge(local.tags, {
    Name = "${var.group_name}-${var.environment}-IGW"
  })
}

# Public Subnets (4 across AZs)
resource "aws_subnet" "public" {
  count                   = 4
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  map_public_ip_on_launch = true
  tags = merge(local.tags, {
    Name = "${var.group_name}-${var.environment}-PublicSubnet-${count.index + 1}"
    Type = "Public"
  })
}

# Private Subnets (2 across AZs)
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 4)
  availability_zone = data.aws_availability_zones.available.names[count.index % length(data.aws_availability_zones.available.names)]
  tags = merge(local.tags, {
    Name = "${var.group_name}-${var.environment}-PrivateSubnet-${count.index + 1}"
    Type = "Private"
  })
}

# NAT Gateway in Public Subnet 1
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = merge(local.tags, {
    Name = "${var.group_name}-${var.environment}-NAT-EIP"
  })
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id  # Explicitly use first public subnet
  tags = merge(local.tags, {
    Name = "${var.group_name}-${var.environment}-NATGW"
  })
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = merge(local.tags, {
    Name = "${var.group_name}-${var.environment}-Public-RT"
  })
}

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = merge(local.tags, {
    Name = "${var.group_name}-${var.environment}-Private-RT"
  })
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Add ALB security group to network module
resource "aws_security_group" "alb" {
  name        = "${var.group_name}-${var.environment}-ALB-SG"
  description = "ALB Security Group"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, { 
    Name = "${var.group_name}-${var.environment}-ALB-SG"
  })
}