output "vpc_main_id" {
  value = "${aws_vpc.vpc_main.id}"
}

output "subnet_main_public_id" {
  value = "${aws_subnet.subnet_main_public.id}"
}

output "subnet_main_private_id" {
  value = "${aws_subnet.subnet_main_private.id}"
}
