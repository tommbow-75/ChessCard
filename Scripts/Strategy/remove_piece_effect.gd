class_name RemovePieceEffect
extends StrategyEffectTiming

## 移除棋子效果
## 預設：單體敵方、馬/車/砲/兵（shooting_SC）
## boulder_SC 等以 .tres 覆寫 effect_target / piece_mask / target_mode

func _init() -> void:
	target_type = TargetType.new()
	target_type.type = TargetType.Type.PIECE
	effect_target = EffectTarget.new()
	effect_target.target = EffectTarget.Target.ENEMY
	piece_mask = TargetPieceMask.new()
	piece_mask.mask = (
			TargetPieceMask.HORSE
			| TargetPieceMask.CHARIOT
			| TargetPieceMask.CANNON
			| TargetPieceMask.SOLDIER
	)
	target_mode = TargetMode.new()
	target_mode.mode = TargetMode.Mode.SINGLE

func execute(context: Dictionary) -> void:
	var game = context.get("game")
	var affected: Array = context.get("affected_positions", [])
	for pos in affected:
		var target = game.board.get_piece(pos)
		if target != null:
			game.board.remove_piece(pos)
