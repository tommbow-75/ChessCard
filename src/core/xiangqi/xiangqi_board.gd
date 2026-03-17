class_name XiangqiBoard
extends RefCounted

# Dictionary mapping Vector2i coordinates to XiangqiPiece objects
var pieces: Dictionary = {}

func clear():
	pieces.clear()

func set_piece(pos: Vector2i, piece: XiangqiPiece):
	pieces[pos] = piece

func get_piece(pos: Vector2i) -> XiangqiPiece:
	return pieces.get(pos, null)

func remove_piece(pos: Vector2i):
	pieces.erase(pos)

func has_piece(pos: Vector2i) -> bool:
	return pieces.has(pos)

func is_out_of_bounds(pos: Vector2i) -> bool:
	# Xiangqi board is 9x10. (0,0) to (8,9)
	# Red is typically at bottom y=5..9, Black at top y=0..4
	return pos.x < 0 or pos.x > 8 or pos.y < 0 or pos.y > 9

func is_in_palace(pos: Vector2i, side: int) -> bool:
	# Palace x is 3..5. Black y is 0..2, Red y is 7..9
	if pos.x < 3 or pos.x > 5:
		return false
	if side == XiangqiPiece.Side.BLACK:
		return pos.y >= 0 and pos.y <= 2
	else:
		return pos.y >= 7 and pos.y <= 9

func is_own_side_half(pos: Vector2i, side: int) -> bool:
	if side == XiangqiPiece.Side.BLACK:
		return pos.y <= 4
	else:
		return pos.y >= 5
