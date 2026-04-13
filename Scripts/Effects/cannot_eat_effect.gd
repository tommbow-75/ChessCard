class_name CannotEatEffect
extends SummonEffectTiming

## 天生效果：禁止此棋子吃掉特定種類的目標
## 用於：垃圾炮（不可吃 GENERAL）
## 擴充：修改 forbidden_target 即可套用至任何棋子種類

@export var forbidden_target: int = XiangqiPiece.PieceType.GENERAL

func _init() -> void:
	timing = Timing.BORN

## 此效果由 XiangqiRuleVerifier 查詢，不透過 execute() 主動發動
func execute(context: Dictionary) -> void:
	pass
