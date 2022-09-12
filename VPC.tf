//VPC
resource "aws_vpc" "jp" {
  cidr_block       = "10.10.0.0/16"
  enable_dns_support   = true # DNS解決を有効化
  enable_dns_hostnames = true # DNSホスト名を有効化

  tags = {
    Name = "terraform_VPC"
  }
}

//Subnet
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.jp.id
  cidr_block = "10.10.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "terraform_publicSubnet"
  }
}
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.jp.id
  cidr_block = "10.10.2.0/24"

  tags = {
    Name = "terraform_privateSubnet"
  }
}

//Internet Gateway
resource "aws_internet_gateway" "jp" {
  vpc_id = aws_vpc.jp.id

  tags = {
    Name = "terraform_internetGateway"
  }
}

//Route Table
resource "aws_route_table" "jp" {
  vpc_id = aws_vpc.jp.id

  tags = {
    Name = "terraform_routeTable"
  }
}

resource "aws_route" "jp" {
  gateway_id             = aws_internet_gateway.jp.id
  route_table_id         = aws_route_table.jp.id
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "jp" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.jp.id
}

//Security Group
resource "aws_security_group" "jp" {
  vpc_id = aws_vpc.jp.id
  name   = "terraform_securityGroup"

  tags = {
    Name = "terraform_securityGroup"
  }
}
# アウトバウンドルール(全開放)
resource "aws_security_group_rule" "out_all" {
  security_group_id = aws_security_group.jp.id
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
}