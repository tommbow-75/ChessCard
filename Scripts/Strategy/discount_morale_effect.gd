class_name DiscountMoraleEffect
extends StrategyEffectTiming

@export var damage_amount: int = 5

func _init() -> void:
	target_type = TargetType.new()
	target_type.type = TargetType.Type.PLAYER
	effect_target = EffectTarget.new()
	piece_mask = TargetPieceMask.new()
	target_mode = TargetMode.new()
	target_mode.mode = TargetMode.Mode.NONE

func execute(context: Dictionary) -> void:
	var game = context.get("game")
	var side = context.get("caster_side")
	if side == XiangqiPiece.Side.RED:
		game.morale_black = max(0, game.morale_black - damage_amount)
		if game.morale_black == 0:
			game.is_game_over = true
			game.winner = XiangqiPiece.Side.RED
	else:
		game.morale_red = max(0, game.morale_red - damage_amount)
		if game.morale_red == 0:
			game.is_game_over = true
			game.winner = XiangqiPiece.Side.BLACK
