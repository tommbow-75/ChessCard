extends StrategyEffectTiming

@export var heal_amount: int = 3

func _init() -> void:
	target_type = TargetType.new()
	target_type.type = TargetType.Type.PLAYER
	effect_target = EffectTarget.new()
	effect_target.target = EffectTarget.Target.SELF
	piece_mask = TargetPieceMask.new()
	target_mode = TargetMode.new()
	target_mode.mode = TargetMode.Mode.NONE

func execute(context: Dictionary) -> void:
	var game = context.get("game")
	var side = context.get("caster_side")
	if side == XiangqiPiece.Side.RED:
		game.morale_red = min(100, game.morale_red + heal_amount)
	else:
		game.morale_black = min(100, game.morale_black + heal_amount)
