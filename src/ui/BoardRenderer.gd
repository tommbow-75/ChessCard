extends Node2D

## 棋盤渲染器：繪製棋盤、高亮、走步提示、吃子紅點

const CELL_SIZE := 70
const COLS := 9
const ROWS := 10
const OFFSET := Vector2(50, 50)

# 由外部 (XiangqiGameUI) 設定
var selected_pos: Vector2i = Vector2i(-1, -1)
var hint_positions: Array[Vector2i] = []      # 合法空格走步

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

	# ── 棋盤背景 ──────────────────────────────────
	draw_rect(
		Rect2(ox - 70, oy - 70, board_width + 140, board_height + 140),
		Color(0.863, 0.71, 0.361)
	)

	# ── 橫線 ──────────────────────────────────────
	for r in range(ROWS):
		var y = oy + r * CELL_SIZE
		draw_line(Vector2(ox, y), Vector2(ox + board_width, y), Color.BLACK, 2)

	# ── 直線（楚河漢界斷線）─────────────────────────
	for c in range(COLS):
		var x = ox + c * CELL_SIZE
		if c == 0 or c == COLS - 1:
			draw_line(Vector2(x, oy), Vector2(x, oy + board_height), Color.BLACK, 2)
		else:
			draw_line(Vector2(x, oy), Vector2(x, oy + 4 * CELL_SIZE), Color.BLACK, 2)
			draw_line(Vector2(x, oy + 5 * CELL_SIZE), Vector2(x, oy + board_height), Color.BLACK, 2)

	# ── 九宮格斜線 ────────────────────────────────
	draw_line(Vector2(ox + 3*CELL_SIZE, oy),               Vector2(ox + 5*CELL_SIZE, oy + 2*CELL_SIZE), Color.BLACK, 2)
	draw_line(Vector2(ox + 5*CELL_SIZE, oy),               Vector2(ox + 3*CELL_SIZE, oy + 2*CELL_SIZE), Color.BLACK, 2)
	draw_line(Vector2(ox + 3*CELL_SIZE, oy + 7*CELL_SIZE), Vector2(ox + 5*CELL_SIZE, oy + 9*CELL_SIZE), Color.BLACK, 2)
	draw_line(Vector2(ox + 5*CELL_SIZE, oy + 7*CELL_SIZE), Vector2(ox + 3*CELL_SIZE, oy + 9*CELL_SIZE), Color.BLACK, 2)

	# ── 楚河漢界文字 ──────────────────────────────
	var font = ThemeDB.fallback_font
	var font_size = 22
	var river_y = oy + 4 * CELL_SIZE + CELL_SIZE * 0.5
	_draw_river_text(font, font_size, "楚  河", Vector2(ox + CELL_SIZE * 1.5, river_y))
	_draw_river_text(font, font_size, "漢  界", Vector2(ox + CELL_SIZE * 5.5, river_y))

	# ── 兵卒炮包位置十字標示 ─────────────────────────
	_draw_position_marks(ox, oy)

	# ── 合法走步提示（藍色半透明點） ────────────────
	for hint in hint_positions:
		var center = board_to_screen(hint)
		draw_circle(center, 12, Color(0.2, 0.6, 1.0, 0.5))

	# ── 選中棋子高亮（橘色外框） ─────────────────────
	if selected_pos != Vector2i(-1, -1):
		var center = board_to_screen(selected_pos)
		draw_circle(center, CELL_SIZE * 0.42, Color(1.0, 0.6, 0.1, 0.4))
		draw_arc(center, CELL_SIZE * 0.42, 0, TAU, 32, Color(1.0, 0.6, 0.1), 3)

	# ── 座標軸標示 ─────────────────────────────────
	_draw_axis_labels(ox, oy)


# ──────────────────────────────────────────────────────
# 真實棋盤十字（括弧）標示
# 位置：兵=紅y6/黑y3 x=0,2,4,6,8；炮=紅y7/黑y2 x=1,7
# ──────────────────────────────────────────────────────
func _draw_position_marks(ox: float, oy: float):
	var mark_len := 8.0   # 短臂長度
	var gap      := 5.0   # 距交叉點距離

	# 記錄需要畫標示的交叉點
	var marks: Array[Vector2i] = []

	# 兵（紅方 y=6，x=0,2,4,6,8）
	for x in [0, 2, 4, 6, 8]:
		marks.append(Vector2i(x, 6))

	# 卒（黑方 y=3，x=0,2,4,6,8）
	for x in [0, 2, 4, 6, 8]:
		marks.append(Vector2i(x, 3))

	# 炮（紅方 y=7，x=1,7）
	marks.append(Vector2i(1, 7))
	marks.append(Vector2i(7, 7))

	# 包（黑方 y=2，x=1,7）
	marks.append(Vector2i(1, 2))
	marks.append(Vector2i(7, 2))

	for m in marks:
		var cx = ox + m.x * CELL_SIZE
		var cy = oy + m.y * CELL_SIZE
		_draw_cross_bracket(cx, cy, mark_len, gap, m.x, m.y)

## 在 (cx,cy) 畫括弧形十字標記，根據邊界判斷要畫哪幾個角
func _draw_cross_bracket(cx: float, cy: float, arm: float, gap: float, gx: int, gy: int):
	var col = Color(0.1, 0.1, 0.1, 0.85)
	var w   = 1.5

	var has_left  = gx > 0
	var has_right = gx < COLS - 1
	var has_up    = gy > 0
	var has_down  = gy < ROWS - 1

	# 上左角
	if has_up and has_left:
		draw_line(Vector2(cx - gap - arm, cy - gap), Vector2(cx - gap,         cy - gap), col, w)
		draw_line(Vector2(cx - gap,       cy - gap), Vector2(cx - gap,         cy - gap - arm), col, w)
	# 上右角
	if has_up and has_right:
		draw_line(Vector2(cx + gap + arm, cy - gap), Vector2(cx + gap,         cy - gap), col, w)
		draw_line(Vector2(cx + gap,       cy - gap), Vector2(cx + gap,         cy - gap - arm), col, w)
	# 下左角
	if has_down and has_left:
		draw_line(Vector2(cx - gap - arm, cy + gap), Vector2(cx - gap,         cy + gap), col, w)
		draw_line(Vector2(cx - gap,       cy + gap), Vector2(cx - gap,         cy + gap + arm), col, w)
	# 下右角
	if has_down and has_right:
		draw_line(Vector2(cx + gap + arm, cy + gap), Vector2(cx + gap,         cy + gap), col, w)
		draw_line(Vector2(cx + gap,       cy + gap), Vector2(cx + gap,         cy + gap + arm), col, w)

func _draw_river_text(font: Font, font_size: int, text: String, pos: Vector2):
	var text_width = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var ascent     = font.get_ascent(font_size)
	var text_height = font.get_height(font_size)
	var draw_pos = pos + Vector2(-text_width * 0.5, ascent - text_height * 0.5)
	draw_string(font, draw_pos, text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, Color(0.3, 0.15, 0.0, 0.85))

## 棋盤 XY 座標軸標示
## X 軸：棋盤上方，1~9 對應 col 0~8
## Y 軸：棋盤左方，1~10 對應 row 0~9
func _draw_axis_labels(ox: float, oy: float):
	var font = ThemeDB.fallback_font
	var font_size = 14
	var col = Color(0.2, 0.2, 0.5, 0.9)

	# X 軸（上方）
	for c in range(COLS):
		var label = str(c)
		var lw = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		var x = ox + c * CELL_SIZE - lw * 0.5
		var y = oy - 15 - font.get_descent(font_size)
		draw_string(font, Vector2(x, y), label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, col)

	# Y 軸（左方）
	for r in range(ROWS):
		var label = str(9 - r)
		var lw = font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		var x = ox - lw - 15
		var ascent = font.get_ascent(font_size)
		var y = oy + r * CELL_SIZE + ascent * 0.5
		draw_string(font, Vector2(x, y), label, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, col)

