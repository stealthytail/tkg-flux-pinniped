data "aws_iam_policy" "permissions_boundary" {
  name = "PowerUserPermissionsBoundaryPolicy"
}

locals {
  permissions_boundary = data.aws_iam_policy.permissions_boundary.arn
}

data "aws_iam_role" "control-plane" {
  name = var.controlplane_node_role_name
}

resource "aws_iam_role" "kiam" {
  name                 = "kiam${var.kiam_role_domain}"
  permissions_boundary = local.permissions_boundary
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : data.aws_iam_role.control-plane.arn
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
  inline_policy {
    name = "assume-roles"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "sts:AssumeRole"
          ],
          "Resource" : "*"
        }
      ]
    })
  }
}

locals {
  assumed_by_kiam_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "",
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : resource.aws_iam_role.kiam.arn
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}
