data "aws_iam_policy_document" "kms_policy" {
  statement {
    effect = "Allow"
    actions = ["kms:Decrypt"]
    resources = [local.kms_key_arn]
  }
}

resource "aws_iam_role" "role" {
  name = local.aws.name
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}

EOF
}

resource "aws_iam_role_policy_attachment" "s3_role_policy_policy" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ses_role_policy_attachment" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSESFullAccess"
}

resource "aws_iam_instance_profile" "profile" {
  name = local.aws.name
  role = aws_iam_role.role.name
}

resource "aws_iam_role_policy" "kms_policy" {
  name = local.aws.name
  role = aws_iam_role.role.id
  policy = data.aws_iam_policy_document.kms_policy.json
}