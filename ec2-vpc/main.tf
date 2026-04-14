resource "aws_vpc" "prod" {
  cidr_block = var.default_cidr_block
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
  destination_cidr_block = "0.0.0.0/0"
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

  # depends on works with whole block not just argument eg .id in this case
  depends_on = [ aws_internet_gateway.prod-igw ]
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

# EC2 instance key 
resource "aws_key_pair" "prod_key" {
  key_name = "terra-file-key"
  public_key = file("terra-file-key.pub")
}

# EC2 instance security group
resource "aws_security_group" "public_sg" {
    name = "public_sg"
    description = "this is used for public server "
    vpc_id = aws_vpc.prod.id

    #inbound rules
    ingress {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]         
    }

    #outbound
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]        
    }
}

# EC2 instance 
resource "aws_instance" "ec2_vm" {
    count = 2
    ami = var.default_ami_image
    instance_type = var.default_instance_type

    key_name = aws_key_pair.prod_key.key_name

    vpc_security_group_ids = [ aws_security_group.public_sg.id ]

    subnet_id = aws_subnet.prod-public-subnet.id

    # Bool is required for this
    associate_public_ip_address = true
    
    root_block_device {
      volume_size = 15
      volume_type = "gp3"
    }

    tags = {
      Name = "bastion-vm"
    }
}



#Private vm for services

# security groups
resource "aws_security_group" "private-sg" {
  name = "private-sg"
  description = "Private VM should have this"
  vpc_id = aws_vpc.prod.id

  # inbound
  ingress {
    description = "SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  # outbound
  egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]      
  }
}

# EC2 instance

resource "aws_instance" "private-vm" {
    for_each = tomap({
      "backend_nano" = "t2.nano"
      "backend_micro" = "t2.micro"
    })
    ami = var.default_ami_image
    instance_type = each.value

    key_name = aws_key_pair.prod_key.key_name

    vpc_security_group_ids = [ aws_security_group.private-sg.id ]

    subnet_id = aws_subnet.prod-private-subnet.id

    root_block_device {
      volume_size = var.prod_env == "prod" ? 20 : var.default_root_volume
      volume_type = "gp3"
    }

    depends_on = [ aws_instance.ec2_vm , aws_security_group.private-sg ]

    tags = {
      Name = each.key
    }
}