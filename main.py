from fastapi import FastAPI
from mangum import Mangum
import boto3
import os

app = FastAPI()

@app.get("/items")
def get_items():
    # DynamoDB アクセス例
    dynamodb = boto3.resource("dynamodb")
    table = dynamodb.Table(os.environ["TABLE_NAME"])

    # テーブルから一部アイテムを取得するなど
    # 簡単のため静的レスポンス
    return {"message": "Hello from FastAPI + Lambda + DynamoDB"}

@app.post("/items")
def create_item(item: dict):
    dynamodb = boto3.resource("dynamodb")
    table = dynamodb.Table(os.environ["TABLE_NAME"])

    # POST された内容をアイテムとして DynamoDB に書き込む
    table.put_item(Item=item)

    return {"result": "Item created!"}

# Lambda との接続を行う Mangum ハンドラ
handler = Mangum(app)
