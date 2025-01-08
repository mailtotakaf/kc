from itertools import combinations, product


def is_square(points):
    # 点の組み合わせから正方形かどうかを判定する
    if len(points) != 4:
        return False

    # 距離を全て計算する
    distances = sorted((abs(x1 - x2)**2 + abs(y1 - y2)**2) for (x1, y1), (x2, y2) in combinations(points, 2))
    return distances[0] > 0 and distances[0] == distances[1] == distances[2] == distances[3] and distances[4] == distances[5]


def generate_possible_moves(point):
    # 1つの碁石を1マス動かす
    x, y = point
    return [(x + dx, y + dy) for dx, dy in product([-1, 0, 1], repeat=2) if dx != 0 or dy != 0]


def alert_on_square_or_pre_square(stones):
    for i, stone in enumerate(stones):
        # 現在の碁石配置
        remaining_stones = stones[:i] + stones[i+1:]
        # 動かした場合の全ての可能性
        for move in generate_possible_moves(stone):
            new_positions = remaining_stones + [move]
            if is_square(new_positions):
                print("アラート: 次の1手で正方形になります!", new_positions)
                return

            # 1手前の状態を確認
            for j, check_stone in enumerate(remaining_stones):
                pre_remaining_stones = remaining_stones[:j] + remaining_stones[j+1:]
                for pre_move in generate_possible_moves(check_stone):
                    pre_new_positions = pre_remaining_stones + [pre_move] + [move]
                    if is_square(pre_new_positions):
                        print("アラート: 正方形1手前です!", pre_new_positions)
                        return
    print("問題なし")


# 碁石の初期配置
stones = [(0, 0), (0, 1), (1, 0), (2, 2)]

# アラートチェック
alert_on_square_or_pre_square(stones)
