locals {
    config      = yamldecode(try(
                    file("${path.root}/../../../config.dec.yaml"),
                    file("${path.root}/../../../config.yaml")
                    ))
    aws         = local.config.aws
    kms_key_arn = local.config.volatile_encryption_key
}