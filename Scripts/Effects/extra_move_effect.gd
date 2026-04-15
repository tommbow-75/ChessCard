class_name ExtraMoveEffect
extends SummonEffectTiming

## 一次性效果：移動後（不限吃子）可以再移動一次
## 用於：火焰車

func _init() -> void:
	timing = Timing.ONCE

## 火焰車目前的邏輯設定為「只要有此效果且點選發動，就給一次額外移動」。
## 如果未來需要限制「必須是第一步沒吃子才能點」，可以在此實作。
func can_execute(context: Dictionary) -> bool:
	var game: XiangqiGame = context.get("game_state")
	# 基本驗證：確保遊戲存在且尚未獲發額外移動能力
	return game != null and not game.pending_extra_move

func execute(context: Dictionary) -> void:
	var game: XiangqiGame = context.get("game_state")
	if game == null:
		return
	game.pending_extra_move = true
