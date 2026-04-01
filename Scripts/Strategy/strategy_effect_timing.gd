class_name StrategyEffectTiming
extends Resource

@export var target_type: TargetType
@export var effect_target: EffectTarget
@export var piece_mask: TargetPieceMask
@export var target_mode: TargetMode

func is_valid_target(board_pos: Vector2i, context: Dictionary) -> bool:
	if target_type == null or target_type.type == TargetType.Type.PLAYER:
		return false
	if target_mode == null or target_mode.mode == TargetMode.Mode.NONE:
		return false

	var game = context.get("game")
	if game == null:
		return false

	if target_mode.mode == TargetMode.Mode.AREA_3X3:
		return true

	return _cell_matches(board_pos, game, context.get("caster_side"))

func get_affected_cells(center: Vector2i, context: Dictionary) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	if target_type == null or target_type.type == TargetType.Type.PLAYER:
		return result
	if target_mode == null or target_mode.mode == TargetMode.Mode.NONE:
		return result

	var game = context.get("game")
	if game == null:
		return result
	var side = context.get("caster_side")

	match target_mode.mode:
		TargetMode.Mode.SINGLE:
			if _cell_matches(center, game, side):
				result.append(center)
		TargetMode.Mode.AREA_3X3:
			for dx in range(-1, 2):
				for dy in range(-1, 2):
					var p = Vector2i(center.x + dx, center.y + dy)
					if not game.board.is_out_of_bounds(p) and _cell_matches(p, game, side):
						result.append(p)
		_:
			pass
	return result

func execute(_context: Dictionary) -> void:
	pass

func _cell_matches(pos: Vector2i, game, caster_side: int) -> bool:
	var piece = game.board.get_piece(pos)
	if piece == null:
		return false

	var enemy_side = XiangqiPiece.Side.BLACK if caster_side == XiangqiPiece.Side.RED else XiangqiPiece.Side.RED

	if effect_target != null:
		match effect_target.target:
			EffectTarget.Target.SELF:
				if piece.side != caster_side:
					return false
			EffectTarget.Target.ENEMY:
				if piece.side != enemy_side:
					return false
			EffectTarget.Target.ANY:
				pass

	if piece_mask != null:
		return piece_mask.matches(piece.type)
	return true
