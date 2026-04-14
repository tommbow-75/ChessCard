extends Node2D

## 提示疊層（繪製在 PiecesLayer 之上）
## 同時負責 ONCE 效果浮框（最高層 Node2D，確保在棋子上方繪製）

const CELL_SIZE := 70
const OFFSET := Vector2(50, 50)

var capture_positions: Array = []
var strategy_targets: Array = []
var strategy_hover_poses: Array = []
var is_targeting: bool = false
var all_pieces_on_board: Array = []

## ONCE 效果高亮：當前回合有可發動 ONCE 效果的我方棋子位置
var once_effect_positions: Array[Vector2i] = []

# ── ONCE 浮框狀態（由 XiangqiGameUI 設定，此處繪製）────────
## 是否顯示浮框（點擊棋子後鎖定）
var once_popup_visible: bool = false
## 浮框對應的棋子 Grid 座標
var once_popup_grid_pos: Vector2i = Vector2i(-1, -1)
## 效果描述文字列表（由 GameUI 組裝後傳入）
var once_popup_lines: Array[String] = []

## 輸出 Rect（供 XiangqiGameUI 做點擊 hit-test，單位：HintOverlay 本地座標）
var once_popup_rect: Rect2 = Rect2()
var once_activate_btn_rect: Rect2 = Rect2()
var once_cancel_btn_rect: Rect2 = Rect2()


func board_to_screen(grid_pos: Vector2i) -> Vector2:
	return OFFSET + Vector2(grid_pos.x * CELL_SIZE, grid_pos.y * CELL_SIZE)

func _draw():
	# ── 吃子紅點 ──────────────────────────────────────
	for cap in capture_positions:
		var center = board_to_screen(cap)
		draw_circle(center, 12, Color(1.0, 0.2, 0.2, 0.75))

	# ── 謀略卡目標暗化遮罩 ────────────────────────────
	if is_targeting:
		for p in all_pieces_on_board:
			if p not in strategy_targets:
				var center = board_to_screen(p)
				draw_circle(center, 33, Color(0.0, 0.0, 0.0, 0.6))

	# ── 謀略卡滑鼠懸停橘點 ────────────────────────────
	for h_pos in strategy_hover_poses:
		if h_pos in strategy_targets:
			var center = board_to_screen(h_pos)
			draw_circle(center, 12, Color(1.0, 0.5, 0.0, 1.0))

	# ── ONCE 效果棋子綠色外圈高亮 ─────────────────────
	for once_pos in once_effect_positions:
		var center = board_to_screen(once_pos)
		draw_circle(center, 36, Color(0.1, 0.9, 0.3, 0.18))
		draw_arc(center, 33, 0, TAU, 48, Color(0.15, 0.95, 0.35, 0.95), 2.5)

	# ── ONCE 浮框（最後繪製，確保在最上層）─────────────
	if once_popup_visible and once_popup_grid_pos != Vector2i(-1, -1):
		_draw_once_popup()


func _draw_once_popup() -> void:
	if once_popup_lines.is_empty():
		return

	var font := ThemeDB.fallback_font
	var title_font_size := 15
	var body_font_size  := 13
	var btn_font_size   := 14

	var padding    := Vector2(14.0, 10.0)
	var line_gap   := 5.0
	var btn_height := 28.0
	var btn_gap    := 8.0
	var popup_width := 220.0

	# 計算浮框總高度
	var content_height: float = float(title_font_size) + padding.y
	for _l in once_popup_lines:
		content_height += float(body_font_size) + line_gap
	content_height += btn_height + padding.y * 2.0 + btn_gap

	# 浮框定錨（棋子右上偏移）
	var piece_screen: Vector2 = board_to_screen(once_popup_grid_pos)
	var popup_x: float = piece_screen.x + 40.0
	var popup_y: float = piece_screen.y - content_height * 0.5

	# 邊界夾緊
	var vp := get_viewport_rect().size
	popup_x = clampf(popup_x, 4.0, vp.x - popup_width - 4.0)
	popup_y = clampf(popup_y, 4.0, vp.y - content_height - 4.0)

	var popup_rect := Rect2(popup_x, popup_y, popup_width, content_height)
	once_popup_rect = popup_rect

	# ── 背景：淡灰色半透明 ──
	draw_rect(popup_rect, Color(0.90, 0.91, 0.92, 0.93))
	# ── 邊框：深綠色 ──
	draw_rect(popup_rect, Color(0.1, 0.55, 0.25, 1.0), false, 2.0)

	var cursor_y: float = popup_y + padding.y

	# ── 標題 ──
	var title := "⚡ 一次性技能"
	var title_x: float = popup_x + padding.x
	draw_string(font,
			Vector2(title_x, cursor_y + font.get_ascent(title_font_size)),
			title, HORIZONTAL_ALIGNMENT_LEFT, -1, title_font_size,
			Color(0.08, 0.42, 0.18))
	cursor_y += float(title_font_size) + padding.y

	# ── 效果描述 ──
	for line_text in once_popup_lines:
		var full_line := "• " + line_text
		draw_string(font,
				Vector2(popup_x + padding.x, cursor_y + font.get_ascent(body_font_size)),
				full_line, HORIZONTAL_ALIGNMENT_LEFT,
				int(popup_width - padding.x * 2), body_font_size,
				Color(0.12, 0.12, 0.12))
		cursor_y += float(body_font_size) + line_gap

	cursor_y += btn_gap

	# ── 發動按鈕（綠） ──
	var btn_w: float = (popup_width - padding.x * 2.0 - btn_gap) * 0.5

	var activate_rect := Rect2(popup_x + padding.x, cursor_y, btn_w, btn_height)
	once_activate_btn_rect = activate_rect
	draw_rect(activate_rect, Color(0.15, 0.68, 0.28, 0.95))
	draw_rect(activate_rect, Color(0.08, 0.44, 0.18, 1.0), false, 1.5)
	var act_text := "發動"
	var act_tw: float = font.get_string_size(act_text, HORIZONTAL_ALIGNMENT_LEFT, -1, btn_font_size).x
	draw_string(font,
			Vector2(activate_rect.position.x + (btn_w - act_tw) * 0.5,
					activate_rect.position.y + font.get_ascent(btn_font_size)
					+ (btn_height - font.get_height(btn_font_size)) * 0.5),
			act_text, HORIZONTAL_ALIGNMENT_LEFT, -1, btn_font_size, Color(1, 1, 1))

	# ── 取消按鈕（紅） ──
	var cancel_rect := Rect2(popup_x + padding.x + btn_w + btn_gap, cursor_y, btn_w, btn_height)
	once_cancel_btn_rect = cancel_rect
	draw_rect(cancel_rect, Color(0.72, 0.15, 0.15, 0.90))
	draw_rect(cancel_rect, Color(0.50, 0.08, 0.08, 1.0), false, 1.5)
	var cancel_text := "取消"
	var cancel_tw: float = font.get_string_size(cancel_text, HORIZONTAL_ALIGNMENT_LEFT, -1, btn_font_size).x
	draw_string(font,
			Vector2(cancel_rect.position.x + (btn_w - cancel_tw) * 0.5,
					cancel_rect.position.y + font.get_ascent(btn_font_size)
					+ (btn_height - font.get_height(btn_font_size)) * 0.5),
			cancel_text, HORIZONTAL_ALIGNMENT_LEFT, -1, btn_font_size, Color(1, 0.88, 0.88))
