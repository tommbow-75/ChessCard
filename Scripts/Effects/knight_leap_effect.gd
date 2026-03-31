class_name KnightLeapEffect
extends SummonEffectTiming

## 一次性效果：允許此棋子使用一次超距跳躍走法
## 走到相對位置 (±1,±3) 或 (±3,±1) 均合法（無視拐馬腳）
## 用於：騎士
## 觸發後此效果會被 XiangqiGame 從效果列表移除，
## 並將 piece.knight_leap_available 設為 true 以供 Verifier 判斷

func _init() -> void:
	timing = Timing.ONCE

## context 需包含：
##   "piece" -> XiangqiPiece
func execute(context: Dictionary) -> void:
	var piece: XiangqiPiece = context.get("piece")
	if piece == null:
		return
	piece.knight_leap_available = true
