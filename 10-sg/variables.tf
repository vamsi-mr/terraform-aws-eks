variable "project" {
  default = "roboshop"
}

variable "environment" {
  default = "dev"
}

variable "bastion_sg_name" {
  default = "bastion"
}

variable "bastion_sg_description" {
  default = "created sg for bastion instance"
}

variable "vpn_sg" {
  default = "vpn"
}

variable "vpn_sg_description" {
  default = "created for vpn"
}

variable "ingress_alb_sg" {
  default = "ingress-alb"
}

variable "ingress_alb_sg_description" {
  default = "created for ingress-alb component"
}

variable "ingress_sg" {
  default = "ingress"
}

variable "ingress_sg_description" {
  default = "created sg for ingress instance"
}

variable "eks_control_plane_sg" {
  default = "eks control plane"
}

variable "eks_control_plane_sg_description" {
  default = "created sg for eks control plane"
}

variable "eks_node_sg" {
  default = "eks node"
}

variable "eks_node_sg_description" {
  default = "created sg for eks node"
}