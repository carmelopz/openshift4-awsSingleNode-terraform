resource "aws_subnet" "private" {
  for_each = local.az_set

  vpc_id = aws_vpc.vpc.id

  cidr_block        = cidrsubnet(local.private_cidr_range, 3, index(var.availability_zones, each.value))
  availability_zone = "${var.region}${each.value}"

  tags = merge(
    {
      "Name" = "${var.cluster_name}-private-${each.value}"
    },
    var.tags,
  )
}

resource "aws_route_table" "private_rt" {
  for_each = local.az_set

  vpc_id = aws_vpc.vpc.id

  tags = merge(
    {
      "Name" = "${var.cluster_name}-private-rt-${each.value}"
    },
    var.tags,
  )
}

resource "aws_route" "nat_gateway" {
  for_each = local.az_set

  route_table_id         = aws_route_table.private_rt[each.value].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.subnet_nat_gateway[each.value].id
}

resource "aws_route_table_association" "private_rta" {
  for_each = local.az_set

  route_table_id = aws_route_table.private_rt[each.value].id
  subnet_id      = aws_subnet.private[each.value].id
}