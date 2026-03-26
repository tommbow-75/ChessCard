class_name HealMoraleEffect
extends StragetyEffect

@export var heal_amount: int = 3

func _init() -> void:
	target_type = TargetType.NONE

func execute(context: Dictionary) -> void:
	var game = context.get("game")
	var side = context.get("caster_side")
	if side == XiangqiPiece.Side.RED:
		game.morale_red = min(100, game.morale_red + heal_amount)
	else:
		game.morale_black = min(100, game.morale_black + heal_amount)
