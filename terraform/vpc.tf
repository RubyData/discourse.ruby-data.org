resource "aws_vpc" "vpc_main" {
  cidr_block = "10.100.0.0/16"

  enable_dns_support = true
  enable_dns_hostnames = true

  tags {
    Name = "vpc-discourse-${terraform.workspace}"
  }
}

variable "public_subnet_cidr_blocks" {
  type = "list"
  default = [
    "10.100.0.0/24",
    "10.100.2.0/24"
  ]
}

variable "private_subnet_cidr_blocks" {
  type = "list"
  default = [
    "10.100.1.0/24",
    "10.100.3.0/24"
  ]
}

resource "aws_subnet" "subnet_main_public" {
  count = 2
  vpc_id = "${aws_vpc.vpc_main.id}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block = "${var.public_subnet_cidr_blocks[count.index]}"

  tags {
    Name = "subnet-main-public-${count.index + 1}-discourse-${terraform.workspace}"
  }
}

resource "aws_subnet" "subnet_main_private" {
  count = 2
  vpc_id = "${aws_vpc.vpc_main.id}"
  availability_zone = "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block = "${var.private_subnet_cidr_blocks[count.index]}"

  tags {
    Name = "subnet-main-private-${count.index + 1}-discourse-${terraform.workspace}"
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
  count = 2
  subnet_id = "${element(aws_subnet.subnet_main_public.*.id, count.index)}"
  route_table_id = "${aws_route_table.rt_main_public.id}"
}

resource "aws_route_table_association" "rta_main_private" {
  count = 2
  subnet_id = "${element(aws_subnet.subnet_main_private.*.id, count.index)}"
  route_table_id = "${aws_route_table.rt_main_private.id}"
}
