locals {
    config   = yamldecode(try(
                file("${path.root}/../../../config.dec.yaml"),
                file("${path.root}/../../../config.yaml")
                ))
    zerotier = local.config.zerotier
}