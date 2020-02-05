resource "aws_lb" "internal_api" {
    name = "${var.cluster_name}-internal-api-elb"
    internal = true
    load_balancer_type = "network"
    subnets = values(aws_subnet.private)[*].id
    enable_cross_zone_load_balancing = true

    tags = merge(
        {
            "Name" = "${var.cluster_name}-internal-api-elb"
        },
        var.tags,
    )
}

resource "aws_lb_target_group" "internal_api" {
    name = "${var.cluster_name}-internal-api-elb-tg"
    port = "6443"
    protocol = "TCP"
    vpc_id = aws_vpc.vpc.id

    tags = merge(
        {
            "Name" = "${var.cluster_name}-internal-api-elb-tg"
        },
        var.tags,
    )

    health_check {
        interval = "10"
        path = "/readyz"
        port = "6443"
        protocol = "HTTPS"
    }
}