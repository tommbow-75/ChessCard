class_name TurnIntoEffect
extends StrategyEffectTiming

## 變換棋子效果
## 用途：
##  - 上馬（horse_SC）    ：任何非將帥棋子 → HORSE
##  - 機械化（mechanized）：任何 SOLDIER → CHARIOT
##  - 策反（rebel_SC）   ：敵方非將帥 → 己方基礎棋子

enum TransformResult {
	TO_HORSE,       # 目標變為馬
	TO_CHARIOT,     # 目標變為車
	TO_ALLY,        # 目標陣營改為發動方（策反）
}

@export var transform_result: TransformResult = TransformResult.TO_HORSE

func _init() -> void:
	# 預設為上馬（horse_SC）
	target_faction    = TargetFaction.ANY
	target_piece_mask = PIECE_ALL & ~PIECE_GENERAL
	target_mode       = TargetMode.SINGLE

func execute(context: Dictionary) -> void:
	var game        = context.get("game")
	var caster_side = context.get("caster_side")
	var affected: Array = context.get("affected_positions", [])

	for pos in affected:
		var target = game.board.get_piece(pos)
		if target == null:
			continue
		match transform_result:
			TransformResult.TO_HORSE:
				target.type = XiangqiPiece.PieceType.HORSE
			TransformResult.TO_CHARIOT:
				target.type = XiangqiPiece.PieceType.CHARIOT
			TransformResult.TO_ALLY:
				target.side = caster_side
				target.special_effects.clear()
