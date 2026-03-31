class_name DrawCardEffect
extends StrategyEffectTiming

@export var draw_amount: int = 1

func _init() -> void:
	target_mode = TargetMode.NONE  # 直接發動，不需選格

func execute(context: Dictionary) -> void:
	var game = context.get("game")
	var side = context.get("caster_side")
	var deck = game.deck_red if side == XiangqiPiece.Side.RED else game.deck_black
	for i in range(draw_amount):
		deck.draw_card()
