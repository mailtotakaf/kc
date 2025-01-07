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

provider "aws" {
  region = "ap-northeast-1"  # 必要に応じて変更
}

########################################
# DynamoDB テーブル
########################################
resource "aws_dynamodb_table" "example" {
  name         = "example-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

########################################
# Lambda 実行ロール & ポリシー
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

# Lambda から DynamoDB へアクセスするためのポリシー
data "aws_iam_policy_document" "lambda_policy" {
  statement {
    actions = [
      "dynamodb:PutItem",
      "dynamodb:GetItem",
      "dynamodb:UpdateItem",
      "dynamodb:DeleteItem",
      "dynamodb:Scan",
      "dynamodb:Query"
    ]
    resources = [
      aws_dynamodb_table.example.arn
    ]
  }
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_dynamodb_policy"
  role = aws_iam_role.lambda_execution_role.id
  policy = data.aws_iam_policy_document.lambda_policy.json
}

########################################
# Lambda 関数
########################################
resource "aws_lambda_function" "example" {
  function_name = "example-lambda"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  # あらかじめ zip 化したファイルを指定
  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  # (オプション) Lambdaに環境変数を設定する場合
  # environment {
  #   variables = {
  #     TABLE_NAME = aws_dynamodb_table.example.name
  #   }
  # }
}

########################################
# API Gateway
########################################
resource "aws_api_gateway_rest_api" "example" {
  name        = "example-api"
  description = "Example API for demonstration"
}

# /example というリソースを作成
resource "aws_api_gateway_resource" "example_resource" {
  rest_api_id = aws_api_gateway_rest_api.example.id
  parent_id   = aws_api_gateway_rest_api.example.root_resource_id
  path_part   = "example"
}

# GET /example メソッド
resource "aws_api_gateway_method" "example_method" {
  rest_api_id   = aws_api_gateway_rest_api.example.id
  resource_id   = aws_api_gateway_resource.example_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# Lambda を AWS_PROXY で呼び出す設定
resource "aws_api_gateway_integration" "example_integration" {
  rest_api_id             = aws_api_gateway_rest_api.example.id
  resource_id             = aws_api_gateway_resource.example_resource.id
  http_method             = aws_api_gateway_method.example_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.example.invoke_arn
}

# デプロイ
resource "aws_api_gateway_deployment" "example_deployment" {
  depends_on = [
    aws_api_gateway_integration.example_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.example.id
  stage_name  = "dev"
}

# Lambda への実行権限をAPI Gatewayに付与
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = aws_api_gateway_deployment.example_deployment.execution_arn
}
