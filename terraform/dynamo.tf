resource "aws_dynamodb_table" "kc_stones" {
  name         = "kc_stones"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "gameid_moves"
  range_key = "created_at"

  attribute {
    name = "gameid_moves"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "S"
  }

  # TTL に使用する属性の名前を指定
  ttl {
    attribute_name = "ttl"  # データ側で UNIX タイムスタンプを入れる必要がある
    enabled        = true
  }

  tags = {
    Environment = "dev"
    Name        = "kc-stones"
  }
}
