class_name RemovePieceEffect
extends StragetyEffect

## 移除棋子效果
## 可配置為：
##  - 單體移除（shooting_SC）：faction=ENEMY，mask=不含將/相/仕，mode=SINGLE
##  - 範圍移除（boulder_SC） ：faction=ANY，mask=不含GENERAL，mode=AREA_3X3

func _init() -> void:
	# 預設為單體敵方移除（shooting_SC 設定）
	target_faction    = TargetFaction.ENEMY
	target_piece_mask = PIECE_ALL & ~PIECE_GENERAL & ~PIECE_ADVISOR & ~PIECE_ELEPHANT
	target_mode       = TargetMode.SINGLE

func execute(context: Dictionary) -> void:
	var game = context.get("game")
	var affected: Array = context.get("affected_positions", [])
	for pos in affected:
		var target = game.board.get_piece(pos)
		if target != null:
			game.board.remove_piece(pos)
