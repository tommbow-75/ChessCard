class_name XiangqiRuleSystem
extends Node

## 中國象棋基本規則與走子驗證系統
## 依賴 GridSystem (網格與佈局) 與 ChessPieceData (棋子定義 - PieceType, Camp)

# 判斷起點到終點是否為合法走法
# grid: 引用的 GridSystem 實例
func is_valid_move(grid, from_pos: Vector2, to_pos: Vector2, current_camp: int) -> bool:
	# 基本邊界檢驗
	if not grid.is_valid_pos(from_pos) or not grid.is_valid_pos(to_pos):
		return false
	
	# 起點與終點不能相同
	if from_pos == to_pos:
		return false
	
	var moving_piece = grid.get_piece_at(from_pos)
	if moving_piece == null:
		return false
	
	# 只能移動我方陣營的棋子
	if moving_piece.camp != current_camp:
		return false
		
	var target_piece = grid.get_piece_at(to_pos)
	if target_piece != null:
		# 目標格有棋子且為己方陣營，不可吃自己
		if target_piece.camp == moving_piece.camp:
			return false
			
	var dx = to_pos.x - from_pos.x
	var dy = to_pos.y - from_pos.y
	
	match moving_piece.type:
		0: # PieceType.GENERAL (將/帥)
			return _is_valid_general_move(grid, from_pos, to_pos, dx, dy, current_camp)
		1: # PieceType.ADVISOR (士/仕)
			return _is_valid_advisor_move(from_pos, to_pos, dx, dy, current_camp)
		2: # PieceType.ELEPHANT (象/相)
			return _is_valid_elephant_move(grid, from_pos, to_pos, dx, dy, current_camp)
		3: # PieceType.CHARIOT (車)
			return _is_valid_chariot_move(grid, from_pos, to_pos, dx, dy)
		4: # PieceType.HORSE (馬)
			return _is_valid_horse_move(grid, from_pos, to_pos, dx, dy)
		5: # PieceType.CANNON (炮)
			return _is_valid_cannon_move(grid, from_pos, to_pos, dx, dy, target_piece != null)
		6: # PieceType.SOLDIER (兵/卒)
			return _is_valid_soldier_move(from_pos, dx, dy, current_camp)
			
	return false

# 檢查路徑上是否有棋子阻擋 (供車、炮使用)
func _get_pieces_count_in_path(grid, from_pos: Vector2, to_pos: Vector2) -> int:
	var count = 0
	if from_pos.x == to_pos.x:
		var step = 1 if to_pos.y > from_pos.y else -1
		var y = from_pos.y + step
		while y != to_pos.y:
			if grid.get_piece_at(Vector2(from_pos.x, y)) != null:
				count += 1
			y += step
	elif from_pos.y == to_pos.y:
		var step = 1 if to_pos.x > from_pos.x else -1
		var x = from_pos.x + step
		while x != to_pos.x:
			if grid.get_piece_at(Vector2(x, from_pos.y)) != null:
				count += 1
			x += step
	return count

# 車: 直走或直向移動，中間不能有棋子
func _is_valid_chariot_move(grid, from_pos: Vector2, to_pos: Vector2, dx: float, dy: float) -> bool:
	if dx != 0 and dy != 0:
		return false
	return _get_pieces_count_in_path(grid, from_pos, to_pos) == 0

# 炮: 吃子時必需隔一個棋子，不吃子時中間不能有棋子
func _is_valid_cannon_move(grid, from_pos: Vector2, to_pos: Vector2, dx: float, dy: float, is_capture: bool) -> bool:
	if dx != 0 and dy != 0:
		return false
	var count = _get_pieces_count_in_path(grid, from_pos, to_pos)
	if is_capture:
		return count == 1
	else:
		return count == 0

# 馬: 走日字，判斷拐馬腳
func _is_valid_horse_move(grid, from_pos: Vector2, _to_pos: Vector2, dx: float, dy: float) -> bool:
	if abs(dx) == 1 and abs(dy) == 2:
		var check_y = from_pos.y + sign(dy)
		if grid.get_piece_at(Vector2(from_pos.x, check_y)) != null: # 拐馬腳 (直向)
			return false
		return true
	elif abs(dx) == 2 and abs(dy) == 1:
		var check_x = from_pos.x + sign(dx)
		if grid.get_piece_at(Vector2(check_x, from_pos.y)) != null: # 拐馬腳 (橫向)
			return false
		return true
	return false

# 象/相: 走田字，不能過河，判斷塞象眼
func _is_valid_elephant_move(grid, from_pos: Vector2, to_pos: Vector2, dx: float, dy: float, camp: int) -> bool:
	if abs(dx) != 2 or abs(dy) != 2:
		return false
	# 不能過河 (紅下黑上)
	if camp == 0 and to_pos.y < 5: # 假設 Red 在下方 (y >= 5)
		return false
	if camp == 1 and to_pos.y > 4: # 假設 Black 在上方 (y <= 4)
		return false
		
	# 塞象眼檢查
	var eye_pos = Vector2(from_pos.x + dx/2.0, from_pos.y + dy/2.0)
	if grid.get_piece_at(eye_pos) != null:
		return false
	return true

# 士/仕: 只能在九宮格內走斜線
func _is_valid_advisor_move(_from_pos: Vector2, to_pos: Vector2, dx: float, dy: float, camp: int) -> bool:
	if abs(dx) != 1 or abs(dy) != 1:
		return false
	return _is_in_palace(to_pos, camp)

# 帥/將: 只能在九宮格內走直線 (王見王需在遊戲流程另外處理吃子)
func _is_valid_general_move(grid, from_pos: Vector2, to_pos: Vector2, dx: float, dy: float, camp: int) -> bool:
	# 直線走1步
	if (abs(dx) == 1 and dy == 0) or (dx == 0 and abs(dy) == 1):
		return _is_in_palace(to_pos, camp)
	
	# 王見王「飛將」判斷 (目標必須是對方的將，且中間沒有阻擋) - 可由上層邏輯包裝使用
	var target = grid.get_piece_at(to_pos)
	if target != null and target.type == 0 and target.camp != camp:
		if dx == 0 and _get_pieces_count_in_path(grid, from_pos, to_pos) == 0:
			return true
	
	return false

# 輔助：判斷是否在九宮格內 (假設 x: 3~5 是九宮格，y: 0~2 或 7~9)
func _is_in_palace(pos: Vector2, camp: int) -> bool:
	if pos.x < 3 or pos.x > 5:
		return false
	if camp == 0: # RED at bottom
		return pos.y >= 7 and pos.y <= 9
	else: # BLACK at top
		return pos.y >= 0 and pos.y <= 2

# 兵/卒: 過河前只能向前，過河後可以左右
func _is_valid_soldier_move(from_pos: Vector2, dx: float, dy: float, camp: int) -> bool:
	if abs(dx) + abs(dy) != 1:
		return false
		
	var is_crossed = false
	var forward_y = 0
	if camp == 0: # RED 往上走 (y減小)
		is_crossed = from_pos.y <= 4
		forward_y = -1
	else: # BLACK 往下走 (y增加)
		is_crossed = from_pos.y >= 5
		forward_y = 1
		
	# 沒有過河只能往前
	if not is_crossed:
		return dy == forward_y and dx == 0
	else:
		# 過河後可往前或左右，但不能後退
		return dy == forward_y or (dy == 0 and abs(dx) == 1)
