locals {
  descriptive_name = "${join("-", split(" ", lower(var.descriptive_name)))}"
  role_identifier  = "${var.service_name == "" ? var.product_domain : var.service_name}-${local.descriptive_name}"
  name_prefix      = "LambdaRole_${local.role_identifier}"
}

module "random" {
  source = "github.com/traveloka/terraform-aws-resource-naming.git?ref=v0.7.1"

  name_prefix   = "${local.name_prefix}"
  resource_type = "iam_role"
}

# Trust relationship policy document for AWS Service.
data "aws_iam_policy_document" "this" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# Module, the parent module.
module "this" {
  source = "../../"

  role_name        = "${module.random.name}"
  role_path        = "/lambda-role/"
  role_description = "Lambda Role for ${local.role_identifier}"

  role_assume_policy         = "${data.aws_iam_policy_document.this.json}"
  role_force_detach_policies = "${var.role_force_detach_policies}"
  role_max_session_duration  = "${var.role_max_session_duration}"
}
