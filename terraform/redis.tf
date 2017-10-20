variable "redis_node_type" {
  type = "map"
  default = {
    prod = "cache.t2.micro"
    test = "cache.t2.micro"
  }
}

resource "aws_elasticache_cluster" "redis" {
  cluster_id = "redis-discourse-${terraform.workspace}"
  engine = "redis"
  engine_version = "3.2.4"
  node_type = "${lookup(var.redis_node_type, terraform.workspace)}"
  port = 6379
  num_cache_nodes = 1

  security_group_ids = [
    "${aws_security_group.sg_redis.id}"
  ]

  subnet_group_name = "${aws_elasticache_subnet_group.redis.name}"
  parameter_group_name = "${aws_elasticache_parameter_group.redis.name}"

  apply_immediately = false

  maintenance_window = "Mon:00:00-Mon:03:00"
  # snapshot_window = "03:00-06:00"
}

resource "aws_elasticache_subnet_group" "redis" {
  name = "redis-sng-discourse-${terraform.workspace}"

  subnet_ids = [
    "${aws_subnet.subnet_main_private.*.id}"
  ]
}

resource "aws_elasticache_parameter_group" "redis" {
  name = "redis-pg-discourse-${terraform.workspace}"
  family = "redis3.2"
}
