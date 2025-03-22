########################################
# Terraform および AWS プロバイダの設定
########################################
terraform {
  required_version = ">= 1.3.0"
}

########################################
# CloudWatch Log Group (任意)
########################################
resource "aws_cloudwatch_log_group" "lambda_log_group2" {
  name              = "/aws/lambda/kc2-lambda"
  retention_in_days = 7
}

########################################
# Lambda 関数
########################################
resource "aws_lambda_function" "kc2" {
  function_name = "kc2-lambda"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  filename         = "../lambda.zip"
  source_code_hash = filebase64sha256("../lambda.zip")
}

########################################
# API Gateway
########################################
resource "aws_api_gateway_rest_api" "kc2" {
  name        = "kc2-api"
  description = "kc2 API for demonstration"
}

resource "aws_api_gateway_resource" "kc2_resource" {
  rest_api_id = aws_api_gateway_rest_api.kc2.id
  parent_id   = aws_api_gateway_rest_api.kc2.root_resource_id
  path_part   = "kc2"
}

resource "aws_api_gateway_method" "kc2_method" {
  rest_api_id   = aws_api_gateway_rest_api.kc2.id
  resource_id   = aws_api_gateway_resource.kc2_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "kc2_integration" {
  rest_api_id             = aws_api_gateway_rest_api.kc2.id
  resource_id             = aws_api_gateway_resource.kc2_resource.id
  http_method             = aws_api_gateway_method.kc2_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.kc2.invoke_arn
}

resource "aws_api_gateway_deployment" "kc2_deployment" {
  depends_on = [
    aws_api_gateway_method.kc2_method,
    aws_api_gateway_integration.kc2_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.kc2.id
  stage_name  = "dev"
}

########################################
# 出力例
########################################
output "api_url2" {
  description = "API Gateway Endpoint"
  value       = "${aws_api_gateway_rest_api.kc2.id}.execute-api.${var.region}.amazonaws.com/dev/kc2"
}
