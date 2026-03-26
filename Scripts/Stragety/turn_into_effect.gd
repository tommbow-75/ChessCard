class_name TurnIntoEffect
extends StragetyEffect

enum TransformTarget {
	ANY_NON_GENERAL_TO_HORSE,
	ANY_SOLDIER_TO_CHARIOT,
	ENEMY_NON_GENERAL_TO_ALLY
}

@export var behavior: TransformTarget = TransformTarget.ANY_NON_GENERAL_TO_HORSE

func _init() -> void:
	target_type = TargetType.SINGLE_ENEMY_NON_GENERAL

func is_valid_target(board_pos: Vector2i, context: Dictionary) -> bool:
	var game = context.get("game")
	var piece = game.board.get_piece(board_pos)
	if piece == null: return false
	
	if behavior == TransformTarget.ANY_NON_GENERAL_TO_HORSE:
		return piece.type != XiangqiPiece.PieceType.GENERAL
	elif behavior == TransformTarget.ANY_SOLDIER_TO_CHARIOT:
		return piece.type == XiangqiPiece.PieceType.SOLDIER
	elif behavior == TransformTarget.ENEMY_NON_GENERAL_TO_ALLY:
		return piece.side != context.get("caster_side") and piece.type != XiangqiPiece.PieceType.GENERAL
	return false

func execute(context: Dictionary) -> void:
	var game = context.get("game")
	var pos: Vector2i = context.get("target_pos")
	var target = game.board.get_piece(pos)
	if target == null: return
	
	if behavior == TransformTarget.ANY_NON_GENERAL_TO_HORSE:
		target.type = XiangqiPiece.PieceType.HORSE
	elif behavior == TransformTarget.ANY_SOLDIER_TO_CHARIOT:
		target.type = XiangqiPiece.PieceType.CHARIOT
	elif behavior == TransformTarget.ENEMY_NON_GENERAL_TO_ALLY:
		target.side = context.get("caster_side")
		target.special_effects.clear()
