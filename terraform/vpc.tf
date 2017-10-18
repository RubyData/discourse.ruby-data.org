resource "aws_vpc" "vpc_main" {
  cidr_block = "10.100.0.0/16"

  enable_dns_support = true
  enable_dns_hostnames = true

  tags {
    Name = "vpc-discourse-${terraform.workspace}"
  }
}

resource "aws_subnet" "subnet_main_public" {
  vpc_id = "${aws_vpc.vpc_main.id}"
  cidr_block = "10.100.0.0/24"

  tags {
    Name = "subnet-main-public-discourse-${terraform.workspace}"
  }
}

resource "aws_subnet" "subnet_main_private" {
  vpc_id = "${aws_vpc.vpc_main.id}"
  cidr_block = "10.100.1.0/24"

  tags {
    Name = "subnet-main-private-discourse-${terraform.workspace}"
  }
}

resource "aws_internet_gateway" "igw_main" {
  vpc_id = "${aws_vpc.vpc_main.id}"

  tags {
    Name = "igw-main-discourse-${terraform.workspace}"
  }
}

resource "aws_route_table" "rt_main_public" {
  vpc_id = "${aws_vpc.vpc_main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw_main.id}"
  }

  tags {
    Name = "rt-main-public-discourse-${terraform.workspace}"
  }
}

resource "aws_route_table" "rt_main_private" {
  vpc_id = "${aws_vpc.vpc_main.id}"

  tags {
    Name = "rt-main-private-discourse-${terraform.workspace}"
  }
}

resource "aws_route_table_association" "rta_main_public" {
  subnet_id = "${aws_subnet.subnet_main_public.id}"
  route_table_id = "${aws_route_table.rt_main_public.id}"
}

resource "aws_route_table_association" "rta_main_private" {
  subnet_id = "${aws_subnet.subnet_main_private.id}"
  route_table_id = "${aws_route_table.rt_main_private.id}"
}
