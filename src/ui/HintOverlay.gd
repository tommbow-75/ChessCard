extends Node2D

## 吃子提示疊層（繪製在 PiecesLayer 之上）

const CELL_SIZE := 70
const OFFSET := Vector2(50, 50)

var capture_positions: Array[Vector2i] = []

func board_to_screen(grid_pos: Vector2i) -> Vector2:
	return OFFSET + Vector2(grid_pos.x * CELL_SIZE, grid_pos.y * CELL_SIZE)

func _draw():
	for cap in capture_positions:
		var center = board_to_screen(cap)
		draw_circle(center, 12, Color(1.0, 0.2, 0.2, 0.75))
