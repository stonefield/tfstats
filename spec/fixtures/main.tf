module "servers" {
  source = "./app-cluster"

  servers = 5
}

module "clients" {
  source = "./app-clients"
  clients = 4
}

module "nodes" {
  source = "./app-nodes"
  nodes = 8
}

resource "aws_autoscaling_group" "this" {
  min_size          = 1
  max_size          = 24
  desired_capacity  = 2
}

resource "aws_launch_template" "this" {

}

data "aws_ssm_parameter" "foo" {
  name = "foo"
}

data "aws_s3_bucket" "selected" {
  bucket = "bucket.test.com"
}

data "aws_route53_zone" "selected" {
  name         = "test.com."
  private_zone = true
}

data "aws_launch_configuration" "ubuntu" {
  name = "test-launch-config"
}
