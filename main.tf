#####################################################
# プロバイダ設定
#####################################################
provider "aws" {
  region = "us-east-1"
}

#####################################################
# IAM ロール (Lambda 用)
#####################################################
data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "lambda_role" {
  name               = "example-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

# ここで AWSLambdaBasicExecutionRole (マネージドポリシー) をアタッチ
resource "aws_iam_role_policy_attachment" "lambda_basic_execution_role" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

#####################################################
# DynamoDB テーブル
#####################################################
resource "aws_dynamodb_table" "sample_table" {
  name           = "sample-terraform-table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

#####################################################
# Lambda 関数
# - ファイルを zip 化し、それをデプロイ
#####################################################
# アーカイブ (zip) を作成
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function.zip"
}

resource "aws_lambda_function" "sample_lambda" {
  function_name = "example-lambda-function"
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.lambda_role.arn
  filename      = data.archive_file.lambda_zip.output_path

  # DynamoDB テーブル名を環境変数で渡す例
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.sample_table.name
    }
  }
}

#####################################################
# API Gateway
# - リソース定義、メソッド定義、Lambda 連携
#####################################################
# REST API 作成
resource "aws_api_gateway_rest_api" "sample_api" {
  name        = "sample-api"
  description = "Sample API with Lambda & DynamoDB"
}

# パス /items を作成
resource "aws_api_gateway_resource" "sample_resource" {
  rest_api_id = aws_api_gateway_rest_api.sample_api.id
  parent_id   = aws_api_gateway_rest_api.sample_api.root_resource_id
  path_part   = "items"
}

# メソッド (GET) を作成 (AUTH 無し)
resource "aws_api_gateway_method" "sample_method" {
  rest_api_id   = aws_api_gateway_rest_api.sample_api.id
  resource_id   = aws_api_gateway_resource.sample_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# API Gateway と Lambda を統合 (AWS_PROXY モード)
resource "aws_api_gateway_integration" "sample_integration" {
  rest_api_id             = aws_api_gateway_rest_api.sample_api.id
  resource_id             = aws_api_gateway_resource.sample_resource.id
  http_method             = aws_api_gateway_method.sample_method.http_method
  integration_http_method = "POST"  # Lambda呼び出し時の method
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.sample_lambda.invoke_arn
}

# API Gateway から Lambda を呼び出せるようにする権限
resource "aws_lambda_permission" "apigw_permission" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sample_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  # execution_arn に対してワイルドカード指定
  source_arn    = "${aws_api_gateway_rest_api.sample_api.execution_arn}/*/*"
}

# デプロイメント作成
resource "aws_api_gateway_deployment" "sample_deployment" {
  rest_api_id = aws_api_gateway_rest_api.sample_api.id
  depends_on = [
    aws_api_gateway_integration.sample_integration,
  ]
}

# ステージ作成
resource "aws_api_gateway_stage" "sample_stage" {
  rest_api_id   = aws_api_gateway_rest_api.sample_api.id
  deployment_id = aws_api_gateway_deployment.sample_deployment.id
  stage_name    = "dev"
}
