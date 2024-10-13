resource "aws_ssm_parameter" "aws_acm_certificate_expense" {
  name  = "/${var.project_name}/${var.environment}/aws_acm_certificate_expense"
  type  = "String"
  value = aws_acm_certificate.expense.arn
}