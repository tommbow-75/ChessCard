class_name HealMoraleEffect
extends CardEffectTiming

## 召喚效果：召喚當下立即回復指定士氣
## 用於：醫生象（+5 士氣）

@export var heal_amount: int = 5

func _init() -> void:
	timing = Timing.SUMMON

## context 需包含：
##   "game_state" -> XiangqiGame
##   "side"       -> XiangqiPiece.Side (施放方)
func execute(context: Dictionary) -> void:
	var game: XiangqiGame = context.get("game_state")
	var side: int = context.get("side", -1)
	if game == null or side == -1:
		return
	if side == XiangqiPiece.Side.RED:
		game.morale_red += heal_amount
	else:
		game.morale_black += heal_amount
