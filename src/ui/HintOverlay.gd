extends Node2D

## 吃子提示疊層（繪製在 PiecesLayer 之上）

const CELL_SIZE := 70
const OFFSET := Vector2(50, 50)

var capture_positions: Array[Vector2i] = []
var strategy_targets: Array[Vector2i] = []
var strategy_hover_poses: Array[Vector2i] = []
var is_targeting: bool = false
var all_piece_pos: Array[Vector2i] = []

func board_to_screen(grid_pos: Vector2i) -> Vector2:
	return OFFSET + Vector2(grid_pos.x * CELL_SIZE, grid_pos.y * CELL_SIZE)

func _draw():
	for cap in capture_positions:
		var center = board_to_screen(cap)
		draw_circle(center, 12, Color(1.0, 0.2, 0.2, 0.75))
		
	# 謀略卡目標選擇狀態（反向：遮罩不能選的「格子上的棋子」）
	if is_targeting:
		for p in all_piece_pos:
			if p not in strategy_targets:
				var center = board_to_screen(p)
				# 繪製半透明黑圈將其暗化
				draw_circle(center, 33, Color(0.0, 0.0, 0.0, 0.6))
		
	# 謀略卡滑鼠懸停 (橘色點) - 支援多重原點 (例如 3x3)
	for h_pos in strategy_hover_poses:
		if h_pos in strategy_targets:
			var center = board_to_screen(h_pos)
			draw_circle(center, 12, Color(1.0, 0.5, 0.0, 1.0))
