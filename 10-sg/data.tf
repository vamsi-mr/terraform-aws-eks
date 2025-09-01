data "aws_ssm_parameter" "vpc_id" {
  name = "/${var.project}/${var.environment}/vpc_id"
}

data "aws_ssm_parameter" "jenkins" {
  name = "/${var.project}/${var.environment}/jenkins"
}