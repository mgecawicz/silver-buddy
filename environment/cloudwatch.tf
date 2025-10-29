resource "aws_cloudwatch_log_group" "test_lambda_function" {
  name = "/aws/lambda/${aws_lambda_function.health_check_lambda.function_name}"

  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "silver_price_lambda" {
  name = "/aws/lambda/${aws_lambda_function.silver_price_lambda.function_name}"

  retention_in_days = 30
}