class_name MoveRightnowEffect
extends StragetyEffect

func _init() -> void:
	target_type = TargetType.NONE

func execute(context: Dictionary) -> void:
	var game = context.get("game")
	var side = context.get("caster_side")
	# rule: dispatch_SC (移動所有己方soldier一格)
	for y in range(10):
		for x in range(9):
			var p = Vector2i(x, y)
			var target = game.board.get_piece(p)
			if target != null and target.side == side and target.type == XiangqiPiece.PieceType.SOLDIER:
				# 兵向前一格
				var forward = -1 if side == XiangqiPiece.Side.RED else 1
				var next_p = Vector2i(p.x, p.y + forward)
				if not game.board.is_out_of_bounds(next_p) and game.board.get_piece(next_p) == null:
					game.board.remove_piece(p)
					game.board.set_piece(next_p, target)
