data "aws_kms_secret" "db_main_prod" {
  secret {
    name = "db_admin_password"
    payload = "AQICAHjY0YIRNPKehpDYwYPo0PJkSxMe0rFP8ihhrFN9n4b90QHtR2NbtBgbfgRJyWBO71DmAAAAhDCBgQYJKoZIhvcNAQcGoHQwcgIBADBtBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDBwUISuqDp/rdSTGIwIBEIBA+MatckYhPd7t2n3rwlvopiFUGlX6wwK/DPxG63M0KqJ9a2tfP0NubTgt0OzRMh6QEkdvB7vdJaf3ZrT7VMnr4A=="
  }
}

data "aws_kms_secret" "db_main_test" {
  secret {
    name = "db_admin_password"
    payload = "AQICAHjY0YIRNPKehpDYwYPo0PJkSxMe0rFP8ihhrFN9n4b90QFcupiHJVvKDYpDNfFx5TD0AAAAhDCBgQYJKoZIhvcNAQcGoHQwcgIBADBtBgkqhkiG9w0BBwEwHgYJYIZIAWUDBAEuMBEEDDTA0MehbNrs7c9CVAIBEIBAUnYG+MPAdqGEAV4zVLm45OHd+hCgzb3p/BT6Yn6wOmG7GjoAvYK/YsrDnOeOjj+voWQBusFdMlR1BvmqeIgXQg=="
  }
}

variable "db_main_instance_class" {
  type = "map"
  default = {
    prod = "db.t2.medium"
    test = "db.t2.micro"
  }
}

variable "db_main_multi_az" {
  type = "map"
  default = {
    prod = false
    test = false
  }
}

variable "db_main_backup_retention_period" {
  type = "map"
  default = {
    prod = 7
    test = 1
  }
}

resource "aws_db_instance" "db_main" {
  identifier = "db-main-discourse-${terraform.workspace}"
  allocated_storage = 10 # in giga bytes
  engine = "postgres"
  engine_version = "9.5.6"

  username = "db_admin"
  password = "${lookup(
    map("prod", data.aws_kms_secret.db_main_prod.db_admin_password,
        "test", data.aws_kms_secret.db_main_test.db_admin_password),
    terraform.workspace
  )}"
  instance_class = "${lookup(var.db_main_instance_class, terraform.workspace)}"
  storage_type = "gp2"
  port = 5432

  multi_az = "${lookup(var.db_main_multi_az, terraform.workspace, false)}"

  vpc_security_group_ids = [
    "${aws_security_group.sg_postgres.id}"
  ]

  db_subnet_group_name = "${aws_db_subnet_group.db_sng_main.name}"
  parameter_group_name = "${aws_db_parameter_group.db_pg_main.name}"

  backup_retention_period = "${lookup(var.db_main_backup_retention_period, terraform.workspace, 0)}"
  allow_major_version_upgrade = false
  auto_minor_version_upgrade = true
  apply_immediately = false
  skip_final_snapshot = false
  final_snapshot_identifier = "db-main-discourse-${terraform.workspace}"

  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window      = "03:00-06:00"

  tags {
    Name = "db-main-discourse-${terraform.workspace}"
  }
}

resource "aws_db_subnet_group" "db_sng_main" {
  name = "db-sng-main-discourse-${terraform.workspace}"

  subnet_ids = [
    "${aws_subnet.subnet_main_private.*.id}"
  ]

  tags {
    Name = "db-sng-main-discourse-${terraform.workspace}"
  }
}

resource "aws_db_parameter_group" "db_pg_main" {
  name = "db-pg-main-discourse-${terraform.workspace}"
  family = "postgres9.5"
}
