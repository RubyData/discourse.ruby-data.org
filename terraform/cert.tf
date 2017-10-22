data "aws_acm_certificate" "ruby_data_cert" {
  domain = "ruby-data.org"
  statuses = ["ISSUED"]
}
