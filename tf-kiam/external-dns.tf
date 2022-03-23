resource "aws_iam_role" "external-dns" {
  name                 = "external-dns${var.kiam_role_domain}"
  permissions_boundary = local.permissions_boundary
  assume_role_policy   = local.assumed_by_kiam_policy
  inline_policy {
    # external-dns docs
    # ## Amazon Web Services Route 53 Example
    # https://github.com/vmware-tanzu/community-edition/blob/313d8ef0c71f0f930ea79ec5c2c3388981a1fb46/addons/packages/external-dns/0.10.0/README.md
    name = "update-dns"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "route53:ChangeResourceRecordSets"
          ],
          "Resource" : [
            "arn:aws:route53:::hostedzone/*"
          ]
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "route53:ListHostedZones",
            "route53:ListResourceRecordSets"
          ],
          "Resource" : [
            "*"
          ]
        }
      ]
    })
  }
}
