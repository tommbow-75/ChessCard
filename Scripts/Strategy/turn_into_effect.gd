class_name TurnIntoEffect
extends StrategyEffectTiming

## 變換棋子效果（horse_SC / mechanized / rebel_SC 等）
## transform_to：Inspector 單選 — 七種棋子其中一種，或「策反」僅改陣營

enum TransformTo {
	GENERAL = XiangqiPiece.PieceType.GENERAL,
	ADVISOR = XiangqiPiece.PieceType.ADVISOR,
	ELEPHANT = XiangqiPiece.PieceType.ELEPHANT,
	HORSE = XiangqiPiece.PieceType.HORSE,
	CHARIOT = XiangqiPiece.PieceType.CHARIOT,
	CANNON = XiangqiPiece.PieceType.CANNON,
	SOLDIER = XiangqiPiece.PieceType.SOLDIER,
	DEFECT_TO_ALLY,
}

@export var transform_to: TransformTo = TransformTo.HORSE

func _init() -> void:
	target_type = TargetType.new()
	target_type.type = TargetType.Type.PIECE
	effect_target = EffectTarget.new()
	effect_target.target = EffectTarget.Target.ANY
	piece_mask = TargetPieceMask.new()
	piece_mask.mask = TargetPieceMask.DEFAULT_MASK & ~TargetPieceMask.GENERAL
	target_mode = TargetMode.new()
	target_mode.mode = TargetMode.Mode.SINGLE

func execute(context: Dictionary) -> void:
	var game = context.get("game")
	var caster_side = context.get("caster_side")
	var affected: Array = context.get("affected_positions", [])

	for pos in affected:
		var target = game.board.get_piece(pos)
		if target == null:
			continue
		if transform_to == TransformTo.DEFECT_TO_ALLY:
			target.side = caster_side
			target.special_effects.clear()
		else:
			target.type = transform_to as int
