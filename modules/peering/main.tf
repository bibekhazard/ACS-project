resource "aws_vpc_peering_connection" "vpc_peering" {
  peer_vpc_id   = var.peer_vpc_id
  vpc_id        = var.requestor_vpc_id
  auto_accept = true

  tags = merge(var.default_tags, { Name = "${var.prefix}-vpc-peering" })
}


resource "aws_route" "requestor_route" {
  route_table_id            = var.requestor_public_route_table_id
  destination_cidr_block    = var.peer_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}

resource "aws_route" "acceptor_route" {
  for_each = toset(var.acceptor_private_route_table_ids)
  route_table_id            = each.value
  destination_cidr_block    = var.requestor_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.vpc_peering.id
}