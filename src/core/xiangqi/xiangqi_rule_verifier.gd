class_name XiangqiRuleVerifier
extends RefCounted

static func is_valid_move(board: XiangqiBoard, from_pos: Vector2i, to_pos: Vector2i) -> bool:
	if board.is_out_of_bounds(from_pos) or board.is_out_of_bounds(to_pos):
		return false
	if from_pos == to_pos:
		return false

	var piece = board.get_piece(from_pos)
	if piece == null:
		return false

	var target_piece = board.get_piece(to_pos)
	if target_piece != null and target_piece.side == piece.side:
		return false

	if target_piece != null:
		for effect in piece.special_effects:
			if effect is CannotEatEffect and target_piece.type == effect.forbidden_target:
				return false
			if effect is ForbidCaptureNextMoveEffect and effect.applies_to_target(target_piece.type):
				return false

	var valid := false
	match piece.type:
		XiangqiPiece.PieceType.CHARIOT:
			valid = _check_chariot(board, from_pos, to_pos)
		XiangqiPiece.PieceType.HORSE:
			valid = _check_horse(board, from_pos, to_pos)
		XiangqiPiece.PieceType.ELEPHANT:
			valid = _check_elephant(piece.side, board, from_pos, to_pos)
		XiangqiPiece.PieceType.ADVISOR:
			valid = _check_advisor(piece.side, board, from_pos, to_pos)
		XiangqiPiece.PieceType.GENERAL:
			valid = _check_general(piece.side, board, from_pos, to_pos)
		XiangqiPiece.PieceType.CANNON:
			valid = _check_cannon(board, from_pos, to_pos)
		XiangqiPiece.PieceType.SOLDIER:
			valid = _check_soldier(piece.side, board, from_pos, to_pos)

	if not valid:
		for effect in piece.special_effects:
			if effect is DualMovementEffect:
				valid = _check_by_piece_type(effect.extra_piece_type, piece.side, board, from_pos, to_pos)
				if valid:
					break

	if not valid and piece.knight_leap_available:
		valid = _check_knight_leap(from_pos, to_pos)

	if not valid:
		return false

	return _check_flying_general_after_move(board, from_pos, to_pos)

static func _check_by_piece_type(piece_type: int, side: int, board: XiangqiBoard, from_pos: Vector2i, to_pos: Vector2i) -> bool:
	match piece_type:
		XiangqiPiece.PieceType.CHARIOT:
			return _check_chariot(board, from_pos, to_pos)
		XiangqiPiece.PieceType.HORSE:
			return _check_horse(board, from_pos, to_pos)
		XiangqiPiece.PieceType.ELEPHANT:
			return _check_elephant(side, board, from_pos, to_pos)
		XiangqiPiece.PieceType.ADVISOR:
			return _check_advisor(side, board, from_pos, to_pos)
		XiangqiPiece.PieceType.GENERAL:
			return _check_general(side, board, from_pos, to_pos)
		XiangqiPiece.PieceType.CANNON:
			return _check_cannon(board, from_pos, to_pos)
		XiangqiPiece.PieceType.SOLDIER:
			return _check_soldier(side, board, from_pos, to_pos)
	return false

static func _check_knight_leap(from_pos: Vector2i, to_pos: Vector2i) -> bool:
	var dx = abs(to_pos.x - from_pos.x)
	var dy = abs(to_pos.y - from_pos.y)
	return (dx == 1 and dy == 3) or (dx == 3 and dy == 1)

static func count_pieces_between_straight(board: XiangqiBoard, p1: Vector2i, p2: Vector2i) -> int:
	if p1.x != p2.x and p1.y != p2.y:
		return -1

	var count := 0
	if p1.x == p2.x:
		var step_y = 1 if p2.y > p1.y else -1
		var y = p1.y + step_y
		while y != p2.y:
			if board.has_piece(Vector2i(p1.x, y)):
				count += 1
			y += step_y
	else:
		var step_x = 1 if p2.x > p1.x else -1
		var x = p1.x + step_x
		while x != p2.x:
			if board.has_piece(Vector2i(x, p1.y)):
				count += 1
			x += step_x
	return count

static func _check_chariot(board: XiangqiBoard, from_pos: Vector2i, to_pos: Vector2i) -> bool:
	return count_pieces_between_straight(board, from_pos, to_pos) == 0

static func _check_cannon(board: XiangqiBoard, from_pos: Vector2i, to_pos: Vector2i) -> bool:
	var count = count_pieces_between_straight(board, from_pos, to_pos)
	if count == -1:
		return false
	if board.has_piece(to_pos):
		return count == 1
	return count == 0

static func _check_horse(board: XiangqiBoard, from_pos: Vector2i, to_pos: Vector2i) -> bool:
	var dx = abs(to_pos.x - from_pos.x)
	var dy = abs(to_pos.y - from_pos.y)

	if (dx == 1 and dy == 2) or (dx == 2 and dy == 1):
		var block_x = from_pos.x
		var block_y = from_pos.y
		if dx == 2:
			block_x += (to_pos.x - from_pos.x) / 2
		else:
			block_y += (to_pos.y - from_pos.y) / 2
		return not board.has_piece(Vector2i(block_x, block_y))
	return false

static func _check_elephant(side: int, board: XiangqiBoard, from_pos: Vector2i, to_pos: Vector2i) -> bool:
	if not board.is_own_side_half(to_pos, side):
		return false

	var dx = abs(to_pos.x - from_pos.x)
	var dy = abs(to_pos.y - from_pos.y)
	if dx == 2 and dy == 2:
		var eye_x = (from_pos.x + to_pos.x) / 2
		var eye_y = (from_pos.y + to_pos.y) / 2
		return not board.has_piece(Vector2i(eye_x, eye_y))
	return false

static func _check_advisor(side: int, board: XiangqiBoard, from_pos: Vector2i, to_pos: Vector2i) -> bool:
	if not board.is_in_palace(to_pos, side):
		return false

	var dx = abs(to_pos.x - from_pos.x)
	var dy = abs(to_pos.y - from_pos.y)
	return dx == 1 and dy == 1

static func _check_general(side: int, board: XiangqiBoard, from_pos: Vector2i, to_pos: Vector2i) -> bool:
	if not board.is_in_palace(to_pos, side):
		return false

	var dx = abs(to_pos.x - from_pos.x)
	var dy = abs(to_pos.y - from_pos.y)
	return (dx == 1 and dy == 0) or (dx == 0 and dy == 1)

static func _check_soldier(side: int, board: XiangqiBoard, from_pos: Vector2i, to_pos: Vector2i) -> bool:
	var dx = abs(to_pos.x - from_pos.x)
	var dy = to_pos.y - from_pos.y
	var is_forward = (dy == 1) if side == XiangqiPiece.Side.BLACK else (dy == -1)

	if board.is_own_side_half(from_pos, side):
		return is_forward and dx == 0

	if is_forward and dx == 0:
		return true
	if dy == 0 and dx == 1:
		return true
	return false

static func _check_flying_general_after_move(board: XiangqiBoard, from_pos: Vector2i, to_pos: Vector2i) -> bool:
	var piece = board.get_piece(from_pos)
	var original_target = board.get_piece(to_pos)

	board.remove_piece(from_pos)
	board.set_piece(to_pos, piece)

	var valid := true
	var red_general_pos := Vector2i(-1, -1)
	var black_general_pos := Vector2i(-1, -1)

	for y in range(10):
		for x in range(3, 6):
			var pos = Vector2i(x, y)
			var p = board.get_piece(pos)
			if p != null and p.type == XiangqiPiece.PieceType.GENERAL:
				if p.side == XiangqiPiece.Side.RED:
					red_general_pos = pos
				else:
					black_general_pos = pos

	if red_general_pos.x != -1 and black_general_pos.x != -1 and red_general_pos.x == black_general_pos.x:
		var count = count_pieces_between_straight(board, red_general_pos, black_general_pos)
		if count == 0:
			valid = false

	board.remove_piece(to_pos)
	if original_target != null:
		board.set_piece(to_pos, original_target)
	board.set_piece(from_pos, piece)

	return valid
