# Create VPC
resource "aws_vpc" "main" {

  cidr_block           = lookup(var.vpc_infomation, "cidr")
  instance_tenancy     = lookup(var.vpc_infomation, "instance_tenancy")
  enable_dns_support   = lookup(var.vpc_infomation, "dns_support")
  enable_dns_hostnames = lookup(var.vpc_infomation, "dns_hostnames")
  tags = {
    "Name" = lookup(var.vpc_infomation, "tags")
  }
}

# Public
# Create VPC Public Subnet
resource "aws_subnet" "public" {
  for_each                = var.vpc_public_subnet_cidr
  vpc_id                  = aws_vpc.main.id
  cidr_block              = lookup(each.value, "cidr")
  availability_zone       = lookup(each.value, "zone")
  map_public_ip_on_launch = true
  tags = {
    Name = lookup(each.value, "name")
  }
}

# Create Internet GateWay
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "main-igw"
  }
}

# Create Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "public-route_table"
  }
}

# Create Public Route
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

# Public Subnet Association
resource "aws_route_table_association" "public-association" {
  for_each       = var.vpc_public_subnet_cidr
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

# Private
# Create VPC Private Subnet
resource "aws_subnet" "private" {
  for_each                = var.vpc_private_subnet_cidr
  vpc_id                  = aws_vpc.main.id
  cidr_block              = lookup(each.value, "cidr")
  availability_zone       = lookup(each.value, "zone")
  map_public_ip_on_launch = false
  tags = {
    Name = lookup(each.value, "name")
  }
}

# Create Private Route Table
resource "aws_route_table" "private" {
  for_each = var.vpc_private_subnet_cidr
  vpc_id   = aws_vpc.main.id
  tags = {
    Name = "private-route_table-${lookup(each.value, "name")}"
  }
}

# Private Subnet Association
resource "aws_route_table_association" "private-association" {
  for_each       = var.vpc_private_subnet_cidr
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

# Elastic IP
# resource "aws_eip" "main" {
#   for_each = var.vpc_private_subnet_cidr
#   vpc      = true
#   depends_on = [
#     aws_internet_gateway.igw
#   ]
#   tags = {
#     "Name" = "eip-${lookup(each.value, "name")}"
#   }
# }

# No Redundancy mode
resource "aws_eip" "main" {
  vpc = true
  depends_on = [
    aws_internet_gateway.igw
  ]
  tags = {
    "Name" = "eip-${lookup(var.vpc_private_subnet_cidr["param1"], "name")}"
  }
}

# Nat GateWay
# resource "aws_nat_gateway" "main" {
#   for_each      = var.vpc_public_subnet_cidr
#   allocation_id = aws_eip.main[each.key].id
#   subnet_id     = aws_subnet.public[each.key].id
#   depends_on = [
#     aws_internet_gateway.igw
#   ]
#   tags = {
#     "Name" = lookup(each.value, "name")
#   }
# }

# No Redundancy mode
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.main.id
  subnet_id     = aws_subnet.public["param1"].id
  depends_on = [
    aws_internet_gateway.igw
  ]
  tags = {
    "Name" = lookup(var.vpc_public_subnet_cidr["param1"], "name")
  }
}

# Create Private Route
# resource "aws_route" "private" {
#   for_each               = var.vpc_private_subnet_cidr
#   route_table_id         = aws_route_table.private[each.key].id
#   nat_gateway_id         = aws_nat_gateway.main[each.key].id
#   destination_cidr_block = "0.0.0.0/0"
# }

# No Redundancy mode
resource "aws_route" "private" {
  route_table_id         = aws_route_table.private["param1"].id
  nat_gateway_id         = aws_nat_gateway.main.id
  destination_cidr_block = "0.0.0.0/0"
}
