resource "aws_security_group" "controlPlane_sg" {
  name        = "${var.cluster_name}-controlPlane-sg"
  description = "Security group for handling the communication with the control plane nodes"
  vpc_id      = aws_vpc.vpc.id

  tags = merge(
    {
      "Name" = "${var.cluster_name}-controlPlane-sg"
    },
    var.tags
  )
}

resource "aws_security_group_rule" "controlPlane_egress" {
  type              = "egress"
  from_port         = "0"
  to_port           = "0"
  protocol          = "all"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.controlPlane_sg.id
}

resource "aws_security_group_rule" "controlPlane_ingress_services" {
  type              = "ingress"
  from_port         = "22623"
  to_port           = "22623"
  protocol          = "TCP"
  cidr_blocks       = [aws_vpc.vpc.cidr_block]
  security_group_id = aws_security_group.controlPlane_sg.id
}

resource "aws_security_group_rule" "controlPlane_ingress_api" {
  type              = "ingress"
  from_port         = "6443"
  to_port           = "6443"
  protocol          = "TCP"
  cidr_blocks       = [aws_vpc.vpc.cidr_block]
  security_group_id = aws_security_group.controlPlane_sg.id
}

resource "aws_security_group_rule" "controlPlane_ingress_ssh_worker" {
  type              = "ingress"
  from_port         = "22"
  to_port           = "22"
  protocol          = "TCP"
  cidr_blocks       = [aws_vpc.vpc.cidr_block]
  security_group_id = aws_security_group.controlPlane_sg.id
}

resource "aws_security_group_rule" "controlPlane_ingress_etcd" {
  type              = "ingress"
  from_port         = "2379"
  to_port           = "2380"
  protocol          = "TCP"
  security_group_id = aws_security_group.controlPlane_sg.id
  self              = true
}

resource "aws_security_group_rule" "controlPlane_ingress_etcd_worker" {
  type                     = "ingress"
  from_port                = "2379"
  to_port                  = "2380"
  protocol                 = "TCP"
  security_group_id        = aws_security_group.controlPlane_sg.id
  source_security_group_id = aws_security_group.worker_sg.id
}

resource "aws_security_group_rule" "controlPlane_ingress_HLS" {
  type              = "ingress"
  from_port         = "9000"
  to_port           = "9999"
  protocol          = "TCP"
  security_group_id = aws_security_group.controlPlane_sg.id
  self              = true
}

resource "aws_security_group_rule" "controlPlane_ingress_HLS_worker" {
  type                     = "ingress"
  from_port                = "9000"
  to_port                  = "9999"
  protocol                 = "TCP"
  security_group_id        = aws_security_group.controlPlane_sg.id
  source_security_group_id = aws_security_group.worker_sg.id
}

resource "aws_security_group_rule" "controlPlane_ingress_k8s" {
  type              = "ingress"
  from_port         = "10249"
  to_port           = "10259"
  protocol          = "TCP"
  security_group_id = aws_security_group.controlPlane_sg.id
  self              = true
}

resource "aws_security_group_rule" "controlPlane_ingress_k8s_worker" {
  type                     = "ingress"
  from_port                = "10249"
  to_port                  = "10259"
  protocol                 = "TCP"
  security_group_id        = aws_security_group.controlPlane_sg.id
  source_security_group_id = aws_security_group.worker_sg.id
}

resource "aws_security_group_rule" "controlPlane_ingress_openshift_sdn" {
  type              = "ingress"
  from_port         = "10256"
  to_port           = "10256"
  protocol          = "TCP"
  security_group_id = aws_security_group.controlPlane_sg.id
  self              = true
}

resource "aws_security_group_rule" "controlPlane_ingress_openshift_sdn_worker" {
  type                     = "ingress"
  from_port                = "10256"
  to_port                  = "10256"
  protocol                 = "TCP"
  security_group_id        = aws_security_group.controlPlane_sg.id
  source_security_group_id = aws_security_group.worker_sg.id
}

resource "aws_security_group_rule" "controlPlane_ingress_vxlan_geneve" {
  type              = "ingress"
  from_port         = "4789"
  to_port           = "4789"
  protocol          = "UDP"
  security_group_id = aws_security_group.controlPlane_sg.id
  self              = true
}

resource "aws_security_group_rule" "controlPlane_ingress_vxlan_geneve_worker" {
  type                     = "ingress"
  from_port                = "4789"
  to_port                  = "4789"
  protocol                 = "UDP"
  security_group_id        = aws_security_group.controlPlane_sg.id
  source_security_group_id = aws_security_group.worker_sg.id
}

resource "aws_security_group_rule" "controlPlane_ingress_vxlan_geneve_2" {
  type              = "ingress"
  from_port         = "6081"
  to_port           = "6081"
  protocol          = "UDP"
  security_group_id = aws_security_group.controlPlane_sg.id
  self              = true
}

resource "aws_security_group_rule" "controlPlane_ingress_vxlan_geneve_2_worker" {
  type                     = "ingress"
  from_port                = "6081"
  to_port                  = "6081"
  protocol                 = "UDP"
  security_group_id        = aws_security_group.controlPlane_sg.id
  source_security_group_id = aws_security_group.worker_sg.id
}

resource "aws_security_group_rule" "controlPlane_ingress_HLS_UDP" {
  type              = "ingress"
  from_port         = "9000"
  to_port           = "9999"
  protocol          = "UDP"
  security_group_id = aws_security_group.controlPlane_sg.id
  self              = true
}

resource "aws_security_group_rule" "controlPlane_ingress_HLS_UDP_worker" {
  type                     = "ingress"
  from_port                = "9000"
  to_port                  = "9999"
  protocol                 = "UDP"
  security_group_id        = aws_security_group.controlPlane_sg.id
  source_security_group_id = aws_security_group.worker_sg.id
}
resource "aws_security_group_rule" "controlPlane_ingress_k8s_nodePort" {
  type              = "ingress"
  from_port         = "30000"
  to_port           = "32767"
  protocol          = "UDP"
  security_group_id = aws_security_group.controlPlane_sg.id
  self              = true
}

resource "aws_security_group_rule" "controlPlane_ingress_k8s_nodePort_worker" {
  type                     = "ingress"
  from_port                = "30000"
  to_port                  = "32767"
  protocol                 = "UDP"
  security_group_id        = aws_security_group.controlPlane_sg.id
  source_security_group_id = aws_security_group.worker_sg.id
}