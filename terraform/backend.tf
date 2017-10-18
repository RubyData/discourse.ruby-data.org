terraform {
  required_version = ">= 0.10.0"

  backend "s3" {
    bucket = "ruby-data-discourse-terraform"
    key = "discourse.tfstate"
    region = "us-west-2"
  }
}
