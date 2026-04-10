resource "aws_vpc" "prod" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "prod-vpc"
  }
}

resource "aws_subnet" "prod-public-subnet" {
  vpc_id = aws_vpc.prod.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "public-prod-subnet"
  }
}

resource "aws_subnet" "prod-private-subnet" {
  vpc_id = aws_vpc.prod.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "private-prod-subnet"
  }
}

resource "aws_internet_gateway" "prod-igw"{
  vpc_id = aws_vpc.prod.id

  tags = {
    Name = "prod-igw"
  }
}

# public route
resource "aws_route_table" "public-route" {
  vpc_id = aws_vpc.prod.id

  tags = {
    Name = "public-prod-route"
  }
}

resource "aws_route" "public_internet_route" {
  route_table_id = aws_route_table.public-route.id
  destination_cidr_block = "0.0.0.0/16"
  gateway_id = aws_internet_gateway.prod-igw.id
}

resource "aws_route_table_association" "public_assoc" {
  route_table_id = aws_route_table.public-route.id
  subnet_id = aws_subnet.prod-public-subnet.id 
}

# Elastic IP
resource "aws_eip" "nat_eip" {
  domain = "vpc"
}


# NAT gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.prod-public-subnet.id

  tags = {
    Name = "prod-nat-gateway"
  }

  depends_on = [ aws_internet_gateway.prod-igw.id ]
}

# private route
resource "aws_route_table" "private_internet_route" {
  vpc_id = aws_vpc.prod.id

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route" "name" {
  route_table_id = aws_route_table.private_internet_route.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.nat_gw.id
}

resource "aws_route_table_association" "private_assoc" {
  subnet_id = aws_subnet.prod-private-subnet.id
  route_table_id = aws_route_table.private_internet_route.id
}