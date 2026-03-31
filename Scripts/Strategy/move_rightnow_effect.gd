class_name MoveRightnowEffect
extends StrategyEffectTiming

## 調度：移動所有己方 soldier 向前一格（不可吃子）

func _init() -> void:
	target_mode = TargetMode.NONE  # 直接發動（全場掃描，不需選格）

func execute(context: Dictionary) -> void:
	var game = context.get("game")
	var side = context.get("caster_side")
	for y in range(10):
		for x in range(9):
			var p = Vector2i(x, y)
			var target = game.board.get_piece(p)
			if target != null and target.side == side and target.type == XiangqiPiece.PieceType.SOLDIER:
				var forward = -1 if side == XiangqiPiece.Side.RED else 1
				var next_p = Vector2i(p.x, p.y + forward)
				if not game.board.is_out_of_bounds(next_p) and game.board.get_piece(next_p) == null:
					game.board.remove_piece(p)
					game.board.set_piece(next_p, target)
