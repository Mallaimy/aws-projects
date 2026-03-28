# In this section we are going to create private subnet ressources to host RDS and ECS


# creating a elastic IP
resource "aws_eip" "nat-eip" {
    domain = "vpc"
    tags = {
      Name = "ecom-nat-eip"
    }
}

# create Natgatway
resource "aws_nat_gateway" "nat-gw" {
    allocation_id = aws_eip.nat-eip.id
    subnet_id = aws_subnet.public["subnet_1a"].id
    
    tags = {
      Name = " ecom-nat-gwy"
    }
    
    depends_on = [aws_internet_gateway.my-igw]
}


# creating local data for the private subnet

locals {
    private_subnets = {
        subnet_1a = { az = "us-east-1a", cidr = "10.0.3.0/24"}
        subnet_1b = { az = "us-east-1b", cidr = "10.0.4.0/24"}
  }
}

resource "aws_subnet" "private-subnet" {
    for_each                = local.private_subnets
    vpc_id                  = aws_vpc.main.id
    cidr_block              = each.value.cidr
    availability_zone       = each.value.az
    map_public_ip_on_launch = false
    
    
    tags = {
        Name = "private-subnet-${each.value.az}"
    }
}

# create route table
resource "aws_route_table" "private-rt" {
    vpc_id = aws_vpc.main.id

    route {
        cidr_block =  "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat-gw.id
    }

    tags = {
      Name = "private-route-table"
    }
  
}

# route table association
resource "aws_route_table_association" "rt-associ" {
    for_each = local.private_subnets
    subnet_id = aws_subnet.private-subnet[each.key].id
    route_table_id = aws_route_table.private-rt.id
  
}