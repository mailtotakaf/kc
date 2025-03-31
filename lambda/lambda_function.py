import json
import kc_checker

CORS_HEADERS = {
    "Content-Type": "application/json",
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "Content-Type",
    "Access-Control-Allow-Methods": "OPTIONS,POST,GET"
}

def lambda_handler(event, context):
    try:
        body = json.loads(event['body'])

        if isinstance(body, dict) and 'gameid_moves' in body and 'stones' in body:
            # パターン1: 全体に gameid_moves と stones が含まれる形式
            gameid_moves = body["gameid_moves"]
            stones_data = body["stones"]

            kc_flg = {}

            for player, stones in stones_data.items():
                # 各プレイヤーの石を (x, y) タプルに変換
                stones_tuple = [(stone["x"], stone["y"]) for stone in stones.values()]
                # プレイヤーごとにチェック
                kc_flg[player] = kc_checker.alert_on_square_or_pre_square(stones_tuple)
        
        else:
            # パターン2: stones のみが直接来る形式
            stones = body
            gameid_moves = None
            stones_data = None

            print("stones:", stones)
            stones_tuple = [(item["x"], item["y"]) for i, (key, item) in enumerate(stones.items())]
            print("stones_tuple:", stones_tuple)

            kc_flg = kc_checker.alert_on_square_or_pre_square(stones_tuple)

    except (KeyError, json.JSONDecodeError) as e:
        print(f"KeyError or JSONDecodeError: {str(e)}")
        return {
            "statusCode": 400,
            "headers": CORS_HEADERS,
            "body": json.dumps({"error": "Invalid request structure"})
        }
    except Exception as e:
        print(f"Unexpected error: {str(e)}")
        return {
            "statusCode": 500,
            "headers": CORS_HEADERS,
            "body": json.dumps({"error": "Internal server error"})
        }

    return {
        "statusCode": 200,
        "headers": CORS_HEADERS,
        "body": json.dumps({
            "gameid_moves": gameid_moves,
            "kc_flg": kc_flg,
            "stones": stones_data
        })
    }
