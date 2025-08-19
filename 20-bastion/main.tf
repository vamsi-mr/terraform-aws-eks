resource "aws_instance" "bastion" {
  ami                    = local.ami_id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [local.bastion_sg_id]
  subnet_id              = local.public_subnet_id
  iam_instance_profile = "AWS-EKS"  ## no need to configure aws again in bastion

# need more for terraform
root_block_device {
    volume_size = 50
    volume_type = "gp3" # or "gp2", depending on your preference
}
user_data = file("bastion.sh")

  tags = merge(
    local.common_tags,
    {
      Name = "${var.project}-${var.environment}-bastion"
    }
  )
}