resource "aws_subnet" "public" {
  for_each = local.az_set

  vpc_id = aws_vpc.vpc.id

  cidr_block        = cidrsubnet(local.public_cidr_range, 3, index(var.availability_zones, each.value))
  availability_zone = each.value

  tags = merge(
    {
      "Name" = "${var.cluster_name}-public-${each.value}"
    },
    var.tags,
  )
}

resource "aws_internet_gateway" "cluster_igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    {
      "Name" = "${var.cluster_name}-cluster-igw"
    },
    var.tags,
  )
}

resource "aws_route_table" "default" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    {
      "Name" = "${var.cluster_name}-public-rt"
    },
    var.tags,
  )
}

resource "aws_main_route_table_association" "public_rta" {
  vpc_id         = aws_vpc.vpc.id
  route_table_id = aws_route_table.default.id
}

resource "aws_route" "igw_route" {
  destination_cidr_block = "0.0.0.0/0"
  route_table_id         = aws_route_table.default.id
  gateway_id             = aws_internet_gateway.cluster_igw.id
}

resource "aws_route_table_association" "public_rta_subnet" {
  for_each = local.az_set

  route_table_id = aws_route_table.default.id
  subnet_id      = aws_subnet.public[each.value].id
}

resource "aws_eip" "nat_eip" {
  for_each = local.az_set

  vpc = true

  tags = merge(
    {
      "Name" = "${var.cluster_name}-nat-eip-${each.value}"
    },
    var.tags,
  )
}

resource "aws_nat_gateway" "subnet_nat_gateway" {

  for_each = local.az_set

  allocation_id = aws_eip.nat_eip[each.value].id
  subnet_id     = aws_subnet.public[each.value].id

  tags = merge(
    {
      "Name" = "${var.cluster_name}-nat-gateway-${each.value}"
    },
    var.tags,
  )
}