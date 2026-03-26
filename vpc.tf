# chose the provider that you want work with
provider "aws" {
  region = "us-east-1"
}

# congifure your private network
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "ecommerce-vpc"
  }
}

 #creating gateway a means to connect with the outside world (Internet)
resource "aws_internet_gateway" "my-igw" {
    vpc_id = aws_vpc.main.id

    tags ={
        Name = "ecommerce-igw"
    } 
}

# Data: Subnet configuration
locals {
  public_subnets = {
    "subnet_1a" = { az = "us-east-1a", cidr = "10.0.1.0/24" }
    "subnet_1b" = { az = "us-east-1b", cidr = "10.0.2.0/24" }
  }
}

resource "aws_subnet" "public" {
  for_each = local.public_subnets
  vpc_id = aws_vpc.main.id
  cidr_block = each.value.cidr
  availability_zone = each.value.az
  map_public_ip_on_launch = true

  tags = {
    Name ="Public-subnet-${each.value.az}"
  }
}

#Route table

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my-igw.id
  }

  tags = {
    Name = "public-route-table"
  }

}

resource "aws_route_table_association" "rt-association" {
  for_each = local.public_subnets
  subnet_id = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public-rt.id
}