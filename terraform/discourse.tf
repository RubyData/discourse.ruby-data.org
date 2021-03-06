variable "app_discourse_count" {
  type = "map"
  default = {
    prod = 1
    test = 1
  }
}

variable "app_discourse_instance_type" {
  type = "map"
  default = {
    prod = "t2.medium"
    test = "t2.micro"
  }
}

resource "aws_instance" "app_discourse" {
  count = "${lookup(var.app_discourse_count, terraform.workspace)}"

  ami = "${data.aws_ami.ubuntu_xenial.id}"
  instance_type = "${lookup(var.app_discourse_instance_type, terraform.workspace)}"

  disable_api_termination = true
  key_name = "discourse"
  monitoring = true

  vpc_security_group_ids = [
    "${aws_security_group.sg_app.id}"
  ]

  subnet_id = "${element(aws_subnet.subnet_main_public.*.id, count.index % length(data.aws_availability_zones.available.names))}"

  associate_public_ip_address = true

  iam_instance_profile = "${aws_iam_instance_profile.app_discourse.id}"

  user_data = "${data.template_file.discourse_user_data.rendered}"

  tags {
    Name = "${format("app-discourse-${terraform.workspace}-%03d", count.index + 1)}"
  }
}

resource "aws_iam_instance_profile" "app_discourse" {
  name = "app-discourse-${terraform.workspace}"
  role = "${aws_iam_role.app_discourse.name}"
}

resource "aws_iam_role" "app_discourse" {
  name = "app-discourse-${terraform.workspace}"
  assume_role_policy = "${data.aws_iam_policy_document.instance_assume_role_policy.json}"
}

resource "aws_iam_role_policy" "app_discourse_kms" {
  name = "app-discourse-${terraform.workspace}-kms-policy"
  role = "${aws_iam_role.app_discourse.id}"

  policy = "${data.aws_iam_policy_document.app_discourse_kms_policy.json}"
}

data "template_file" "discourse_user_data" {
  template = "${file("templates/discourse_init.sh")}"

  vars = {
    authorized_keys = "${data.template_file.discourse_authorized_keys.rendered}"
    sshd_config_content = "${data.template_file.sshd_config_content.rendered}"
  }
}

data "template_file" "discourse_authorized_keys" {
  template = "${file(format("templates/discourse-%s_authorized_keys", terraform.workspace))}"
}

data "template_file" "sshd_config_content" {
  template = "${file("templates/sshd_config")}"
}

data "aws_iam_policy_document" "instance_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "app_discourse_kms_policy" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt"
    ]
    resources = [
      "arn:aws:kms:us-west-2:349507979381:key/9439f48a-810f-4597-b3c0-4121b6d3311c"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:ListKeys",
      "kms:CreateKey",
      "kms:TagResource"
    ]
    resources = ["*"]
  }
}
