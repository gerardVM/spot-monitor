data "template_file" "installation" {
  template = file("${path.module}/files/installation.sh")

  vars = {
    TOOL_NAME     = local.aws.name
    EMAIL_ADDRESS = local.aws.email
    DOCKER_CONFIG = "/root/.docker"
    S3_BUCKET     = aws_s3_bucket.bucket.bucket
    S3_DC_KEY     = aws_s3_object.docker-compose.key
    S3_CE_KEY     = aws_s3_object.config_email.key
    S3_UK_KEY     = aws_s3_object.uptime_kuma_backup.key
    KMS_KEY       = data.aws_kms_key.by_key_arn.arn
    ZT_NETWORK    = local.aws.zerotier_network
  }
}

data "aws_ami" "ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["${local.aws.image}*"]
  }

  filter {
    name   = "architecture"
    values = ["${local.aws.architecture}"]
  }
}

resource "aws_launch_template" "launch_template" {

  iam_instance_profile {
    name = aws_iam_instance_profile.profile.name
  }

  name_prefix   = local.aws.name
  image_id      = data.aws_ami.ami.id

  instance_market_options {
    market_type = local.aws.market_type
  }

  instance_type = local.aws.instance_type

  monitoring {
    enabled = false
  }  

  vpc_security_group_ids = [aws_security_group.security_group.id]

  user_data = base64encode(data.template_file.installation.rendered)

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name      = local.aws.name
    }
  }
}

resource "aws_instance" "ec2_instance" {
  
  launch_template {
    id              = aws_launch_template.launch_template.id
    version         = "$Latest"
  }
  
  tags = {
    Name            = local.aws.name
  }
}

resource "aws_security_group" "security_group" {
  name_prefix = "${local.aws.name}-"
  description = "No inbound traffic allowed"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = local.aws.name
  }
}