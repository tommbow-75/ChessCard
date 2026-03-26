class_name RemovePieceEffect
extends StragetyEffect

func _init() -> void:
	target_type = TargetType.SINGLE_ENEMY_NON_GENERAL

func is_valid_target(board_pos: Vector2i, context: Dictionary) -> bool:
	var game = context.get("game")
	var piece = game.board.get_piece(board_pos)
	if piece == null:
		if target_type == TargetType.AREA_3X3_ANY:
			return true
		return false
		
	if target_type == TargetType.AREA_3X3_ANY:
		return true

	# 單一敵方非將帥
	if target_type == TargetType.SINGLE_ENEMY_NON_GENERAL:
		if piece.side == context.get("caster_side"): return false
		if piece.type == XiangqiPiece.PieceType.GENERAL or piece.type == XiangqiPiece.PieceType.ADVISOR or piece.type == XiangqiPiece.PieceType.ELEPHANT:
			return false
		return true
		
	return false

func execute(context: Dictionary) -> void:
	var game = context.get("game")
	var pos: Vector2i = context.get("target_pos")
	
	if target_type == TargetType.AREA_3X3_ANY:
		# 移除 3x3 內所有非將帥 (boulder_SC)
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				var p = Vector2i(pos.x + dx, pos.y + dy)
				if not game.board.is_out_of_bounds(p):
					var target = game.board.get_piece(p)
					if target != null and target.type != XiangqiPiece.PieceType.GENERAL:
						game.board.remove_piece(p)
	else:
		# 能量射擊
		var target = game.board.get_piece(pos)
		if target != null:
			game.board.remove_piece(pos)
