module "bastion" {
  #source = "../../terraform-aws-securitygroup"
  source         = "git::https://github.com/vamsi-mr/Terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  sg_name        = var.bastion_sg_name
  sg_description = var.bastion_sg_description
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
}

#bastion accepting connection from my local network through ssh 
resource "aws_security_group_rule" "bastion_local" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.bastion.sg_id
}


module "vpn" {
  #source = "../../terraform-aws-securitygroup"
  source         = "git::https://github.com/vamsi-mr/Terraform-aws-securitygroup.git?ref=main"
  project        = var.project
  environment    = var.environment
  sg_name        = var.vpn_sg
  sg_description = var.vpn_sg_description
  vpc_id         = data.aws_ssm_parameter.vpc_id.value
}

#vpn ports 22, 443, 1194,943
resource "aws_security_group_rule" "vpn_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

resource "aws_security_group_rule" "vpn_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

resource "aws_security_group_rule" "vpn_1194" {
  type              = "ingress"
  from_port         = 1194
  to_port           = 1194
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}

resource "aws_security_group_rule" "vpn_943" {
  type              = "ingress"
  from_port         = 943
  to_port           = 943
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.vpn.sg_id
}


#Ingress ALB
module "ingress_alb" {
    #source = "../../terraform-aws-securitygroup"
    source         = "git::https://github.com/vamsi-mr/Terraform-aws-securitygroup.git?ref=main"
    project = var.project
    environment = var.environment
    sg_name = var.ingress_alb_sg
    sg_description = var.ingress_alb_sg_description
    vpc_id = data.aws_ssm_parameter.vpc_id.value
}

resource "aws_security_group_rule" "ingress_alb_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.ingress_alb.sg_id
}

resource "aws_security_group_rule" "ingress_alb_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.ingress_alb.sg_id
}


module "ingress" {
    #source = "../../terraform-aws-securitygroup"
    source         = "git::https://github.com/vamsi-mr/Terraform-aws-securitygroup.git?ref=main"
    project = var.project
    environment = var.environment
    sg_name = var.ingress_sg
    sg_description = var.ingress_alb_sg_description
    vpc_id = data.aws_ssm_parameter.vpc_id.value
}

resource "aws_security_group_rule" "ingress_ingress_alb" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  source_security_group_id = module.ingress_alb.sg_id
  security_group_id = module.ingress.sg_id
}

resource "aws_security_group_rule" "ingress_vpn" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.vpn.sg_id
  security_group_id = module.ingress.sg_id
}

resource "aws_security_group_rule" "ingress_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.ingress.sg_id
}

module "eks_control_plane" {
    #source = "../../terraform-aws-securitygroup"
    source         = "git::https://github.com/vamsi-mr/Terraform-aws-securitygroup.git?ref=main"
    project = var.project
    environment = var.environment
    sg_name = var.eks_control_plane_sg
    sg_description = var.eks_control_plane_sg_description
    vpc_id = data.aws_ssm_parameter.vpc_id.value
}

resource "aws_security_group_rule" "eks_control_plane_eks_node" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  source_security_group_id = module.eks_node.sg_id
  security_group_id = module.eks_control_plane.sg_id
}

resource "aws_security_group_rule" "eks_control_plane_bastion" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.eks_control_plane.sg_id
}


module "eks_node" {
    #source = "../../terraform-aws-securitygroup"
    source         = "git::https://github.com/vamsi-mr/Terraform-aws-securitygroup.git?ref=main"
    project = var.project
    environment = var.environment
    sg_name = var.eks_node_sg
    sg_description = var.eks_node_sg_description
    vpc_id = data.aws_ssm_parameter.vpc_id.value
}

resource "aws_security_group_rule" "eks_node_eks_control_plane" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  source_security_group_id = module.eks_control_plane.sg_id
  security_group_id = module.eks_node.sg_id
}

resource "aws_security_group_rule" "eks_node_bastion" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  source_security_group_id = module.bastion.sg_id
  security_group_id = module.eks_node.sg_id
}

resource "aws_security_group_rule" "eks_node_vpc" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["10.0.0.0/16"]
  security_group_id = module.vpn.sg_id
}