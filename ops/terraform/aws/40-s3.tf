resource "aws_s3_bucket" "bucket" {
  bucket = "${local.aws.name}-${local.aws.username}"
}

resource "aws_s3_object" "docker-compose" {
  bucket = "${aws_s3_bucket.bucket.id}"
  key    = "docker-compose.yaml"
  source = "files/docker-compose.yaml"
}

resource "aws_s3_object" "config_email" {
  bucket = "${aws_s3_bucket.bucket.id}"
  key    = "config_email.txt"
  source = "files/config_email.txt"
}

resource "aws_s3_object" "uptime_kuma_backup" {
  bucket = "${aws_s3_bucket.bucket.id}"
  key    = "uptime_kuma_backup.base64"
  source = "files/uptime_kuma_backup.base64"
}