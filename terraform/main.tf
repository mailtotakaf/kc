########################################
# Terraform および AWS プロバイダの設定
########################################
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

variable "region" {
  description = "AWS Region for the resources"
  default     = "ap-northeast-1"
}

provider "aws" {
  region = var.region
}

########################################
# IAMロール & ポリシー
########################################
data "aws_iam_policy_document" "lambda_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_execution_role" {
  name               = "lambda_execution_role"
  assume_role_policy = data.aws_iam_policy_document.lambda_trust.json
}

data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan",
      "dynamodb:Query",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = [
      # 必要であれば DynamoDB テーブルのARNをここに追加
      "arn:aws:logs:${var.region}:*:log-group:/aws/lambda/*"
    ]
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda_execution_policy"
  role   = aws_iam_role.lambda_execution_role.id
  policy = data.aws_iam_policy_document.lambda_policy.json
}

########################################
# CloudWatch Log Group (任意)
########################################
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/example-lambda"
  retention_in_days = 7
}

########################################
# Lambda 関数
########################################
resource "aws_lambda_function" "example" {
  function_name = "example-lambda"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  filename         = "../lambda.zip"
  source_code_hash = filebase64sha256("../lambda.zip")
}

########################################
# API Gateway
########################################
resource "aws_api_gateway_rest_api" "example" {
  name        = "example-api"
  description = "Example API for demonstration"
}

resource "aws_api_gateway_resource" "example_resource" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  parent_id   = aws_api_gateway_rest_api.example.root_resource_id
  path_part   = "example"
}

resource "aws_api_gateway_method" "example_method" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  resource_id   = aws_api_gateway_resource.example_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "example_integration" {
  rest_api_id             = aws_api_gateway_rest_api.example.id
  resource_id             = aws_api_gateway_resource.example_resource.id
  http_method             = aws_api_gateway_method.example_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.example.invoke_arn
}

resource "aws_api_gateway_deployment" "example_deployment" {
  depends_on = [
    aws_api_gateway_method.example_method,
    aws_api_gateway_integration.example_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.example.id
  stage_name  = "dev"
}

resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example.function_name
  principal     = "apigateway.amazonaws.com"

  # /dev/* も含めたい場合はこのように記述
  source_arn    = "${aws_api_gateway_rest_api.example.execution_arn}/*"
}

########################################
# 出力例
########################################
output "api_url" {
  description = "API Gateway Endpoint"
  value       = "${aws_api_gateway_rest_api.example.id}.execute-api.${var.region}.amazonaws.com/dev/example"
}
