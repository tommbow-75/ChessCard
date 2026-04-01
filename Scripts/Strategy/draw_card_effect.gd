class_name DrawCardEffect
extends StrategyEffectTiming

@export var draw_amount: int = 1

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
	var deck = game.deck_red if side == XiangqiPiece.Side.RED else game.deck_black
	for i in range(draw_amount):
		deck.draw_card()
