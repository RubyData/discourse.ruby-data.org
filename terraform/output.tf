output "vpc_main_id" {
  value = "${aws_vpc.vpc_main.id}"
}

output "subnet_main_public_ids" {
  value = ["${aws_subnet.subnet_main_public.*.id}"]
}

output "subnet_main_private_ids" {
  value = ["${aws_subnet.subnet_main_private.*.id}"]
}

output "postgres-address" {
  value = "${aws_db_instance.db_main.address}"
}

output "postgres-port" {
  value = "${aws_db_instance.db_main.port}"
}

output "redis-endpoint-address" {
  value = ["${aws_elasticache_cluster.redis.cache_nodes.0.address}"]
}

output "redis-endpoint-port" {
  value = ["${aws_elasticache_cluster.redis.cache_nodes.0.port}"]
}
