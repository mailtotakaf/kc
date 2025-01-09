import json
import kc_checker


def lambda_handler(event, context):
    try:
        stones = json.loads(event['body'])
    except (KeyError, json.JSONDecodeError):
        return {
            "statusCode": 400,
            "stones": json.dumps({"error": "Invalid request stones"})
        }

    stones_tuple = [(item["x"], item["y"]) for i, (key, item) in enumerate(stones.items())]
    # print("stones_tuple:", stones_tuple)
    riichi_flg = kc_checker.alert_on_square_or_pre_square(stones_tuple)
    print("riichi_flg:", riichi_flg)

    return {
        "statusCode": 200,
        "riichi_flg": riichi_flg
    }
