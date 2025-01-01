from fastapi import FastAPI
from mangum import Mangum
import boto3
import os

app = FastAPI()

# 環境変数から DynamoDB のテーブル名を取得
TABLE_NAME = os.environ.get("TABLE_NAME")

@app.get("/items")
def get_items():
    # DynamoDB のリソースを取得
    dynamodb = boto3.resource("dynamodb")
    table = dynamodb.Table(TABLE_NAME)

    # サンプルレスポンスとして DynamoDB を参照する例
    return {"message": "Hello from FastAPI + Lambda + DynamoDB"}

@app.post("/items")
def create_item(item: dict):
    dynamodb = boto3.resource("dynamodb")
    table = dynamodb.Table(TABLE_NAME)

    # POSTされたアイテムをDynamoDBに書き込む
    table.put_item(Item=item)

    return {"result": "Item created!"}

# Mangum ハンドラを定義
handler = Mangum(app)
