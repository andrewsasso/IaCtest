provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "test_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "MyTestVPC"
  }
}

resource "aws_subnet" "my_subnet1_priv" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "MiSubnet1_priv"
  }
}

resource "aws_subnet" "my_subnet2_pub" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "MiSubnet2_pub"
  }
}

resource "aws_eip" "istea_eip" {
  vpc = true
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.test_vpc.id
}

resource "aws_nat_gateway" "test_nat_gateway" {
  allocation_id = aws_eip.istea_eip.id
  subnet_id     = aws_subnet.my_subnet1_priv.id
}

resource "aws_route" "internet_access_pub" {
  route_table_id         = aws_subnet.my_subnet2_pub.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

resource "aws_route" "acceso_internet" {
  route_table_id         = aws_subnet.my_subnet1_priv.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.test_nat_gateway.id
}
