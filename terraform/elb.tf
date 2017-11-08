resource "aws_elb" "elb_app_discourse" {
  name = "app-discourse-${terraform.workspace}"
  subnets = [
    "${aws_subnet.subnet_main_public.*.id}"
  ]
  instances = [
    "${aws_instance.app_discourse.*.id}"
  ]

  listener {
    instance_port = 8880
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  listener {
    instance_port = 8880
    instance_protocol = "http"
    lb_port = 443
    lb_protocol = "https"
    ssl_certificate_id = "${data.aws_acm_certificate.ruby_data_cert.arn}"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 10
    target = "HTTP:8880/"
    interval = 30
  }

  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400

  tags {
    Name = "elb-app-discource-${terraform.workspace}"
  }
}
