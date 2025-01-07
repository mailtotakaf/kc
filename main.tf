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

# Lambda から DynamoDB と CloudWatch Logs にアクセスするためのポリシー
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
      aws_dynamodb_table.example.arn,
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
# CloudWatch Log Group
########################################
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/example-lambda"
  retention_in_days = 7  # 必要に応じて日数を変更
}

########################################
# Lambda 関数
########################################
resource "aws_lambda_function" "example" {
  function_name = "example-lambda"
  role          = aws_iam_role.lambda_execution_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"

  filename         = "lambda_function.zip"
  source_code_hash = filebase64sha256("lambda_function.zip")

  # CloudWatchのログ出力を明示する必要はなく、AWSが自動的に設定
}
