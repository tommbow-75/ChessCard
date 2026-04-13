class_name RestoreOnCaptureEffect
extends SummonEffectTiming
## 繼承自SummonEffectTiming

## 天生效果：每次該棋子吃子後，回復指定士氣
## 用於：猛將（吃子後 +2 士氣）

@export var restore_amount: int = 2

func _init() -> void:
	timing = Timing.BORN

## 此效果由 XiangqiGame._trigger_born_capture_effects() 偵測並呼叫
## context 需包含：
##   "game_state" -> XiangqiGame
##   "side"       -> XiangqiPiece.Side (攻方)
func execute(context: Dictionary) -> void:
	var game: XiangqiGame = context.get("game_state")
	var side: int = context.get("side", -1)
	if game == null or side == -1:
		return
	if side == XiangqiPiece.Side.RED:
		game.morale_red += restore_amount
	else:
		game.morale_black += restore_amount
