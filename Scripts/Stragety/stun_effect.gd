class_name StunEffect
extends StragetyEffect

## 暈眩：選敵方一子（非將帥），下回合不可移動

func _init() -> void:
	target_faction  = TargetFaction.ENEMY
	target_piece_mask = PIECE_ALL & ~PIECE_GENERAL  # 除了將帥之外全部
	target_mode     = TargetMode.SINGLE

func execute(context: Dictionary) -> void:
	var game = context.get("game")
	var affected: Array = context.get("affected_positions", [])
	for pos in affected:
		var target = game.board.get_piece(pos)
		if target != null:
			target.is_stunned = true
			target.stun_duration = 2  # 敵方與我方輪轉各一次 = 1 完整回合
