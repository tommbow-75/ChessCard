class_name DiscountMoraleEffect
extends StragetyEffect

@export var damage_amount: int = 5

func _init() -> void:
	target_type = TargetType.NONE

func execute(context: Dictionary) -> void:
	var game = context.get("game")
	var side = context.get("caster_side")
	# 扣除對方士氣
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
