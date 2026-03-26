extends Node2D

## 單顆棋子的視覺節點
## 由 XiangqiGameUI 動態建立並管理

const CELL_SIZE := 70
const RADIUS := 28.0

# index 順序對應 XiangqiPiece.PieceType:
# 0=GENERAL, 1=ADVISOR, 2=ELEPHANT, 3=HORSE, 4=CHARIOT, 5=CANNON, 6=SOLDIER
const RED_CHARS   := ["帥", "仕", "相", "傌", "俥", "炮", "兵"]
const BLACK_CHARS := ["將", "士", "象", "馬", "車", "包", "卒"]

var piece: XiangqiPiece
var grid_pos: Vector2i

func setup(_piece: XiangqiPiece, _grid_pos: Vector2i, board_offset: Vector2):
	piece = _piece
	grid_pos = _grid_pos
	position = board_offset + Vector2(_grid_pos.x * CELL_SIZE, _grid_pos.y * CELL_SIZE)

func _draw():
	if piece == null:
		return

	if piece.is_stunned:
		modulate = Color(0.5, 0.5, 0.5)
	else:
		modulate = Color(1, 1, 1)

	var is_red = (piece.side == XiangqiPiece.Side.RED)

	# 外圈（深色）
	var outer_color = Color(0.6, 0.1, 0.1) if is_red else Color(0.1, 0.1, 0.1)
	draw_circle(Vector2.ZERO, RADIUS + 3, outer_color)

	# 底色（淡色）
	var fill_color = Color(0.98, 0.93, 0.75) if is_red else Color(0.85, 0.85, 0.85)
	draw_circle(Vector2.ZERO, RADIUS, fill_color)

	# 棋子文字
	var chars = RED_CHARS if is_red else BLACK_CHARS
	var char_text = chars[piece.type] if piece.type < chars.size() else "?"
	var text_color = Color(0.75, 0.1, 0.1) if is_red else Color(0.05, 0.05, 0.05)

	var font = ThemeDB.fallback_font
	var font_size = 26

	# 精確置中：利用 ascent 計算 baseline 位置
	var text_width = font.get_string_size(char_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var ascent    = font.get_ascent(font_size)
	var descent   = font.get_descent(font_size)
	var text_height = ascent + descent

	var draw_pos = Vector2(-text_width * 0.5, ascent - text_height * 0.5)
	draw_string(font, draw_pos, char_text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_color)
