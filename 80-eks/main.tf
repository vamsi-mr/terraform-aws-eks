module "eks" {
  source = "terraform-aws-modules/eks/aws"
  version = "~> 21.0"   ## module version

  name = "${var.project}-${var.environment}"
  kubernetes_version = "1.32"

  addons = {
    coredns = {}
    eks-pod-identity-agent = {
        before_compute = true
    }
    kube-proxy = {}
    vpc-cni    = {
        before_compute = true
    }
    metrics-server = {}
  }

    endpoint_public_access = false
    enable_cluster_creator_admin_permissions = true

    vpc_id                        = local.vpc_id
    subnet_ids                    = local.private_subnet_ids
    control_plane_subnet_ids      = local.private_subnet_ids

    create_node_security_group = false
    create_security_group = false
    security_group_id = local.eks_control_plane_sg_id
    node_security_group_id = local.eks_node_sg_id


    eks_managed_node_groups = {
        blue = {
            ami_type = "AL2023_x86_64_STANDARD"
            instance_types = ["m5.large", "c3.large", "c4.large", "c5.large"]
            min_size = 2
            max_size = 10
            desired_size = 2

            iam_role_additional_policies = {
                AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
                AmazonEFSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
                AmazonEKSLoadBalancingPolicy = "arn:aws:iam::aws:policy/AmazonEKSLoadBalancingPolicy"
            }
        }
    }
    
    tags = merge(
      local.common_tags,
        {
            Name = "${var.project}-${var.environment}"
        }
    )
}
