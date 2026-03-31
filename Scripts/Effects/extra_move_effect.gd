class_name ExtraMoveEffect
extends SummonEffectTiming

## 一次性效果：吃子後可以再移動一次
## 用於：火焰車
## 觸發後此效果會被 XiangqiGame 從效果列表移除

func _init() -> void:
	timing = Timing.ONCE

## context 需包含：
##   "game_state" -> XiangqiGame
func execute(context: Dictionary) -> void:
	var game: XiangqiGame = context.get("game_state")
	if game == null:
		return
	game.pending_extra_move = true
