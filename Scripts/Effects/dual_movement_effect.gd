class_name DualMovementEffect
extends SummonEffectTiming

## 天生效果：此棋子同時擁有另一種棋子的走法
## 用於：鐵衛（同時擁有將帥 & 士仕走法）
## XiangqiRuleVerifier 在驗證時，會額外以 extra_piece_type 的規則跑一次判斷，
## 若任一通過即視為合法走法

@export var extra_piece_type: int = XiangqiPiece.PieceType.GENERAL

func _init() -> void:
	timing = Timing.BORN

## 此效果由 XiangqiRuleVerifier 查詢，不透過 execute() 主動發動
func execute(_context: Dictionary) -> void:
	pass
