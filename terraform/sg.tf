resource "aws_security_group" "sg_allow_internal_ssh" {
  vpc_id = "${aws_vpc.vpc_main.id}"
  name = "allow-internal-ssh-discourse-${terraform.workspace}"
  description = "Allow internal SSH access"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [ "${aws_vpc.vpc_main.cidr_block}" ]
  }

  tags {
    Name = "sg-app-discourse-${terraform.workspace}"
  }
}

resource "aws_security_group" "sg_app" {
  vpc_id = "${aws_vpc.vpc_main.id}"
  name = "app-discourse-${terraform.workspace}"
  description = "Security group for application servers"

  ingress {
    description = "HTTP from anywhere"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS from anywhere"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "sg-app-discourse-${terraform.workspace}"
  }
}

resource "aws_security_group" "sg_postgres_accessible" {
  vpc_id = "${aws_vpc.vpc_main.id}"
  name = "postgres-accessible-discourse-${terraform.workspace}"
  description = "Security group to allow to access postgres servers"

  tags {
    Name = "sg-postgres-accessible-discourse-${terraform.workspace}"
  }
}

resource "aws_security_group" "sg_redis_accessible" {
  vpc_id = "${aws_vpc.vpc_main.id}"
  name = "redis-accessible-discourse-${terraform.workspace}"
  description = "Security group to allow to access redis servers"

  tags {
    Name = "sg-redis-accessible-discourse-${terraform.workspace}"
  }
}

resource "aws_security_group" "sg_postgres" {
  vpc_id = "${aws_vpc.vpc_main.id}"
  name = "postgres-discourse-${terraform.workspace}"
  description = "Security group for postgresql servers"

  ingress {
    description = "Allow incoming trrafic from specific security groups"
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.sg_app.id}",
      "${aws_security_group.sg_postgres_accessible.id}",
    ]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "sg-postgres-discourse-${terraform.workspace}"
  }
}

resource "aws_security_group" "sg_redis" {
  vpc_id = "${aws_vpc.vpc_main.id}"
  name = "redis-discourse-${terraform.workspace}"
  description = "Security group for redis servers"

  ingress {
    description = "Allow incoming trrafic from specific security groups"
    from_port = 6379
    to_port = 6379
    protocol = "tcp"
    security_groups = [
      "${aws_security_group.sg_app.id}",
      "${aws_security_group.sg_redis_accessible.id}",
    ]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "sg-redis-discourse-${terraform.workspace}"
  }
}
