class_name MoveRightnowEffect
extends StrategyEffectTiming

## 調度：選一枚己方符合 mask 的棋子，下一著為額外走子（走完換邊）
## 起點鎖在 pending_extra_move_from；禁吃請同卡掛 ForbidCaptureNextMoveEffect（不設 pending_extra_move，與火焰車區隔）

func _init() -> void:
	target_type = TargetType.new()
	target_type.type = TargetType.Type.PIECE
	effect_target = EffectTarget.new()
	effect_target.target = EffectTarget.Target.SELF
	piece_mask = TargetPieceMask.new()
	piece_mask.mask = TargetPieceMask.SOLDIER
	target_mode = TargetMode.new()
	target_mode.mode = TargetMode.Mode.SINGLE

func execute(context: Dictionary) -> void:
	var game = context.get("game")
	if game == null:
		return
	var affected: Array = context.get("affected_positions", [])
	if affected.is_empty():
		return
	game.pending_extra_move_from = affected[0]
