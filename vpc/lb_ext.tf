resource "aws_lb" "external_api" {
  name                             = "${var.cluster_name}-ext-api-lb"
  internal                         = false
  load_balancer_type               = "network"
  subnets                          = values(aws_subnet.public)[*].id
  enable_cross_zone_load_balancing = true

  tags = merge(
    {
      "Name" = "${var.cluster_name}-external-api-lb"
    },
    var.tags,
  )
}

resource "aws_lb_target_group" "external_api" {
  name     = "${var.cluster_name}-ext-tg"
  port     = "6443"
  protocol = "TCP"
  vpc_id   = aws_vpc.vpc.id

  tags = merge(
    {
      "Name" = "${var.cluster_name}-external-api-lb-tg"
    },
    var.tags,
  )

  health_check {
    interval = "10"
    path     = "/readyz"
    port     = "6443"
    protocol = "HTTPS"
  }
}

resource "aws_lb_listener" "external_api_listener" {
  load_balancer_arn = aws_lb.external_api.arn
  port              = "6443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external_api.arn
  }
}