class_name StunEffect
extends StrategyEffectTiming

## 暈眩：選敵方一子（非將帥），下回合不可移動

func _init() -> void:
	target_type = TargetType.new()
	target_type.type = TargetType.Type.PIECE
	effect_target = EffectTarget.new()
	effect_target.target = EffectTarget.Target.ENEMY
	piece_mask = TargetPieceMask.new()
	piece_mask.mask = TargetPieceMask.DEFAULT_MASK & ~TargetPieceMask.GENERAL
	target_mode = TargetMode.new()
	target_mode.mode = TargetMode.Mode.SINGLE

func execute(context: Dictionary) -> void:
	var game = context.get("game")
	var affected: Array = context.get("affected_positions", [])
	for pos in affected:
		var target = game.board.get_piece(pos)
		if target != null:
			target.is_stunned = true
			target.stun_duration = 2
