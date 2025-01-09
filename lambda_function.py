import json
import kc_checker


def lambda_handler(event, context):
    # リクエストボディを解析
    try:
        stones = json.loads(event['body'])
    except (KeyError, json.JSONDecodeError):
        return {
            "statusCode": 400,
            "stones": json.dumps({"error": "Invalid request stones"})
        }

    # 必要なパラメータを取得
    stone0 = stones.get('stone0')
    stone1 = stones.get('stone1')
    stone2 = stones.get('stone2')
    stone3 = stones.get('stone3')
    print("stone0:", stone0)
    print("stone1:", stone1)
    print("stone2:", stone2)
    print("stone3:", stone3)

    # パラメータが揃っているか確認
    if not all([stone0, stone1, stone2, stone3]):
        return {
            "statusCode": 400,
            "stones": json.dumps({"error": "Missing one or more required parameters: stone0, stone1, stone2, stone3"})
        }

    # stones_tuple = [(item["x"], item["y"]) for item in stones]
    # stones_tuple = [(item["x"], item["y"]) for i, item.get("stone") in enumerate(stones)]
    stones_tuple = [(item["x"], item["y"]) for i, (key, item) in enumerate(stones.items())]
    print("stones_tuple:", stones_tuple)
    riichi_flg = kc_checker.alert_on_square_or_pre_square(stones_tuple)
    return {
        "statusCode": 200,
        "riichi_flg": riichi_flg
    }
    # # ロジックを実行（例: stone0 + stone1, stone2 を計算）
    # result1 = f"{stone0}-{stone1}"  # 単純な例: パラメータを結合
    # result2 = len(stone2)  # stone2 の長さを計算

    # # レスポンスを返す
    # return {
    #     "statusCode": 200,
    #     "stones": json.dumps({
    #         "result1": result1,
    #         "result2": result2
    #     })
    # }
