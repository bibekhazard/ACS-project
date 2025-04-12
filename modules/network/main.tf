locals {
  default_tags = merge(var.default_tags, { "env" = var.env })
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  tags = merge(
    local.default_tags, {
      Name = "${var.prefix}-vpc"
    }
  )
}

resource "aws_subnet" "public_subnet" {
  count             = length(var.public_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.public_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true # Important for public subnets
  tags = merge(
    local.default_tags, {
      Name = "${var.prefix}-public-subnet-${count.index + 1}"
    }
  )
}

resource "aws_subnet" "private_subnet" {
  count             = length(var.private_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge(
    local.default_tags, {
      Name = "${var.prefix}-private-subnet-${count.index + 1}"
    }
  )
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge(local.default_tags,
    {
      Name = "${var.prefix}-igw"
    }
  )
}

resource "aws_nat_gateway" "nat_gw" {
  count         = var.enable_nat_gateway ? 1 : 0
  allocation_id = aws_eip.nat_gw[count.index].id
  subnet_id     = aws_subnet.public_subnet[0].id # Assuming NAT GW in the first public subnet

  tags = merge(var.default_tags, {
    Name = "${var.prefix}-nat-gateway"
  })

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_eip" "nat_gw" {
  count  = var.enable_nat_gateway ? 1 : 0
  domain = "vpc"
  tags   = merge(var.default_tags, { Name = "${var.prefix}-nat-gateway-eip" })
}


resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(local.default_tags, {
    Name = "${var.prefix}-route-public-subnets"
  })
}

resource "aws_route_table_association" "public_route_table_association" {
  count          = length(aws_subnet.public_subnet[*].id)
  route_table_id = aws_route_table.public_subnets.id
  subnet_id      = aws_subnet.public_subnet[count.index].id
}


resource "aws_route_table" "private_subnets" {
  vpc_id = aws_vpc.main.id
  count  = length(var.private_cidr_blocks)

  dynamic "route" { # Use dynamic block for conditional route
    for_each = var.enable_nat_gateway ? [1] : [] # Create route only if NAT GW is enabled
    content {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.nat_gw[0].id # Route to NAT Gateway for internet access
    }
  }

  tags = merge(local.default_tags, {
    Name = "${var.prefix}-route-private-subnets-${count.index + 1}"
  })

  depends_on = [aws_nat_gateway.nat_gw]
}

resource "aws_route_table_association" "private_route_table_association" {
  count          = length(aws_subnet.private_subnet[*].id)
  route_table_id = aws_route_table.private_subnets[count.index].id
  subnet_id      = aws_subnet.private_subnet[count.index].id
}