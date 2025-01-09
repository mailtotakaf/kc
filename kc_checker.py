from itertools import combinations, product


def is_square(points):
    # 4点でない場合は正方形にはなりえない
    if len(points) != 4:
        return False

    # 点のペアを作り、距離を計算
    distances = []
    for p1, p2 in combinations(points, 2):
        distances.append((p1[0] - p2[0])**2 + (p1[1] - p2[1])**2)  # 距離の2乗を使用

    # 距離の種類を集める
    distances = sorted(distances)

    # 正方形の条件: 4つの辺が等しい長さで、2つの対角線が等しい長さ
    # -> 最初の4つの距離（辺の長さ）が等しく、最後の2つの距離（対角線の長さ）が等しい
    return distances[0] > 0 and distances[0] == distances[1] == distances[2] == distances[3] and distances[4] == distances[5]


def generate_possible_moves(point):
    # 1つの碁石を1マス動かす
    x, y = point
    return [(x + dx, y + dy) for dx, dy in product([-1, 0, 1], repeat=2) if dx != 0 or dy != 0]


def alert_on_square_or_pre_square(stones):
    if is_square(stones):
        print("積み（正方形）です!", stones)
        return 2

    for i, stone in enumerate(stones):
        # 現在の碁石配置
        remaining_stones = stones[:i] + stones[i+1:]
        # 動かした場合の全ての可能性
        for move in generate_possible_moves(stone):
            # 1手前の状態を確認
            for j, check_stone in enumerate(remaining_stones):
                pre_remaining_stones = remaining_stones[:j] + remaining_stones[j+1:]
                for pre_move in generate_possible_moves(check_stone):
                    pre_new_positions = pre_remaining_stones + [pre_move] + [move]
                    if is_square(pre_new_positions):
                        print("リーチ!", pre_new_positions)
                        return 1
    # print("問題なし")
    return 0
