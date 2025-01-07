import json

def lambda_handler(event, context):
    # リクエストボディを解析
    try:
        body = json.loads(event['body'])
    except (KeyError, json.JSONDecodeError):
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Invalid request body"})
        }

    # 必要なパラメータを取得
    param1 = body.get('param1')
    param2 = body.get('param2')
    param3 = body.get('param3')
    print("param1:", param1)
    print("param2:", param2)
    print("param3:", param3)

    # パラメータが揃っているか確認
    if not all([param1, param2, param3]):
        return {
            "statusCode": 400,
            "body": json.dumps({"error": "Missing one or more required parameters: param1, param2, param3"})
        }

    # ロジックを実行（例: param1 + param2, param3 を計算）
    result1 = f"{param1}-{param2}"  # 単純な例: パラメータを結合
    result2 = len(param3)  # param3 の長さを計算

    # レスポンスを返す
    return {
        "statusCode": 200,
        "body": json.dumps({
            "result1": result1,
            "result2": result2
        })
    }
