extends Node2D

## 棋盤渲染器：基於 GridUI_v1_demo 的 GridRenderer，增加互動高亮功能

const CELL_SIZE := 70
const COLS := 9
const ROWS := 10
const OFFSET := Vector2(50, 50)

# 由外部 (XiangqiGameUI) 設定
var selected_pos: Vector2i = Vector2i(-1, -1)
var hint_positions: Array[Vector2i] = []

func board_to_screen(grid_pos: Vector2i) -> Vector2:
	return OFFSET + Vector2(grid_pos.x * CELL_SIZE, grid_pos.y * CELL_SIZE)

func screen_to_board(screen_pos: Vector2) -> Vector2i:
	var relative = screen_pos - OFFSET
	var gx = roundi(relative.x / CELL_SIZE)
	var gy = roundi(relative.y / CELL_SIZE)
	return Vector2i(gx, gy)

func _draw():
	var board_width  = (COLS - 1) * CELL_SIZE
	var board_height = (ROWS - 1) * CELL_SIZE
	var ox = OFFSET.x
	var oy = OFFSET.y

	# 棋盤背景
	draw_rect(
		Rect2(ox - 25, oy - 25, board_width + 50, board_height + 50),
		Color(0.863, 0.71, 0.361)
	)

	# 橫線
	for r in range(ROWS):
		var y = oy + r * CELL_SIZE
		draw_line(Vector2(ox, y), Vector2(ox + board_width, y), Color.BLACK, 2)

	# 直線（含楚河漢界斷線）
	for c in range(COLS):
		var x = ox + c * CELL_SIZE
		if c == 0 or c == COLS - 1:
			draw_line(Vector2(x, oy), Vector2(x, oy + board_height), Color.BLACK, 2)
		else:
			draw_line(Vector2(x, oy), Vector2(x, oy + 4 * CELL_SIZE), Color.BLACK, 2)
			draw_line(Vector2(x, oy + 5 * CELL_SIZE), Vector2(x, oy + board_height), Color.BLACK, 2)

	# 九宮格斜線
	draw_line(Vector2(ox + 3*CELL_SIZE, oy),               Vector2(ox + 5*CELL_SIZE, oy + 2*CELL_SIZE), Color.BLACK, 2)
	draw_line(Vector2(ox + 5*CELL_SIZE, oy),               Vector2(ox + 3*CELL_SIZE, oy + 2*CELL_SIZE), Color.BLACK, 2)
	draw_line(Vector2(ox + 3*CELL_SIZE, oy + 7*CELL_SIZE), Vector2(ox + 5*CELL_SIZE, oy + 9*CELL_SIZE), Color.BLACK, 2)
	draw_line(Vector2(ox + 5*CELL_SIZE, oy + 7*CELL_SIZE), Vector2(ox + 3*CELL_SIZE, oy + 9*CELL_SIZE), Color.BLACK, 2)

	# 楚河漢界文字
	var river_y = oy + 4 * CELL_SIZE + CELL_SIZE * 0.5
	_draw_river_text("楚  河", Vector2(ox + CELL_SIZE * 0.5, river_y))
	_draw_river_text("漢  界", Vector2(ox + CELL_SIZE * 4.5, river_y))

	# 合法走步提示（淡藍圓點）
	for hint in hint_positions:
		var center = board_to_screen(hint)
		draw_circle(center, 12, Color(0.2, 0.6, 1.0, 0.5))

	# 選中棋子高亮（橘色外框圓）
	if selected_pos != Vector2i(-1, -1):
		var center = board_to_screen(selected_pos)
		draw_circle(center, CELL_SIZE * 0.42, Color(1.0, 0.6, 0.1, 0.4))
		draw_arc(center, CELL_SIZE * 0.42, 0, TAU, 32, Color(1.0, 0.6, 0.1), 3)

func _draw_river_text(text: String, pos: Vector2):
	# 簡化：用多個字元用 draw_string 繪製（Godot 4 使用 ThemeDB）
	var font = ThemeDB.fallback_font
	var font_size = 22
	draw_string(font, pos - Vector2(0, -font_size * 0.3), text,
		HORIZONTAL_ALIGNMENT_CENTER, -1, font_size, Color(0.3, 0.15, 0.0, 0.8))
