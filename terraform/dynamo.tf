resource "aws_dynamodb_table" "kc-table" {
  name         = "kc-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "gid_uid_moves"
  range_key = "created_at"

  attribute {
    name = "gid_uid_moves"
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
    Name        = "kc-table"
  }
}
