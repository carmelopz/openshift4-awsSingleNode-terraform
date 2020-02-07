resource "aws_lb" "internal_api" {
  name                             = "${var.cluster_name}-int-api-lb"
  internal                         = true
  load_balancer_type               = "network"
  subnets                          = values(aws_subnet.private)[*].id
  enable_cross_zone_load_balancing = true

  tags = merge(
    {
      "Name" = "${var.cluster_name}-internal-api-lb"
    },
    var.tags,
  )
}

resource "aws_lb_target_group" "internal_api" {
  name     = "${var.cluster_name}-int-tg"
  port     = "6443"
  protocol = "TCP"
  vpc_id   = aws_vpc.vpc.id

  tags = merge(
    {
      "Name" = "${var.cluster_name}-internal-api-lb-tg"
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

resource "aws_lb_target_group" "internal_services" {
  name     = "${var.cluster_name}-intsvc-tg"
  port     = "22623"
  protocol = "TCP"
  vpc_id   = aws_vpc.vpc.id

  tags = merge(
    {
      "Name" = "${var.cluster_name}-internal-services-lb-tg"
    },
    var.tags,
  )

  health_check {
    interval = "10"
    path     = "/healthz"
    port     = "22623"
    protocol = "HTTPS"
  }
}

resource "aws_lb_listener" "internal_api_listener" {
  load_balancer_arn = aws_lb.internal_api.arn
  port              = "6443"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_api.arn
  }
}

resource "aws_lb_listener" "internal_services_listener" {
  load_balancer_arn = aws_lb.internal_api.arn
  port              = "22623"
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.internal_services.arn
  }
}