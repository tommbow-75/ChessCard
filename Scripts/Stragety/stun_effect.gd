class_name StunEffect
extends StragetyEffect

func _init() -> void:
	target_type = TargetType.SINGLE_ENEMY_NON_GENERAL

func is_valid_target(board_pos: Vector2i, context: Dictionary) -> bool:
	var game = context.get("game")
	var piece = game.board.get_piece(board_pos)
	if piece == null: return false
	if piece.side == context.get("caster_side"): return false
	if piece.type == piece.PieceType.GENERAL: return false
	return true

func execute(context: Dictionary) -> void:
	var game = context.get("game")
	var pos: Vector2i = context.get("target_pos")
	var target = game.board.get_piece(pos)
	if target != null:
		target.is_stunned = true
		target.stun_duration = 2 # 敵方與我方輪轉各一次 = 1完整回合
