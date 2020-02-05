output "public_subnets" {
  value = aws_subnet.public
}

output "private_subnets" {
  value = aws_subnet.private
}

output "zone_private_subnet" {
  value = zipmap(values(aws_subnet.private)[*].availability_zone, values(aws_subnet.private)[*].id)
}

output "zone_public_subnet" {
  value = zipmap(values(aws_subnet.public)[*].availability_zone, values(aws_subnet.public)[*].id)
}
