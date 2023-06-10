data "aws_kms_key" "by_key_arn" {
  key_id = local.kms_key_arn
}