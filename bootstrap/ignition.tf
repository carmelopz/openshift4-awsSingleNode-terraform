resource "aws_s3_bucket" "ignition_config" {
  bucket = var.cluster_name

  tags = merge(
    {
      "Name" = "${var.cluster_name}-s3-ignition-config"
    },
    var.tags,
  )
}

