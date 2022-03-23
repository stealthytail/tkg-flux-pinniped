resource "aws_iam_role" "cert-manager" {
  name                 = "cert-manager${var.kiam_role_domain}"
  permissions_boundary = local.permissions_boundary
  assume_role_policy   = local.assumed_by_kiam_policy
  inline_policy {
    # https://cert-manager.io/docs/configuration/acme/dns01/route53/
    name = "update-dns"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "route53:GetChange",
          "Resource" : "arn:aws:route53:::change/*"
        },
        {
          "Effect" : "Allow",
          "Action" : [
            "route53:ChangeResourceRecordSets",
            "route53:ListResourceRecordSets"
          ],
          "Resource" : "arn:aws:route53:::hostedzone/*"
        },
        {
          "Effect" : "Allow",
          "Action" : "route53:ListHostedZonesByName",
          "Resource" : "*"
        }
      ]
    })
  }
}
