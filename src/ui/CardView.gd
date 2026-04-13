extends Node2D

## CardView：依照 card_demo_v1.png / stragety_card_demo_v1.png 繪製單張卡牌
## 支援 SummonCardData（召喚卡）與 StrategyCardData（謀略卡）兩種模式

const CARD_W := 180.0
const CARD_H := 260.0

# 各區段高度
const HEADER_H := 44.0
const IMAGE_H  := 110.0
const EFFECT_H := 60.0
const FOOTER_H := 34.0

# 顏色
const C_BORDER     := Color(0.05, 0.05, 0.05)
const C_RED_BORDER := Color(0.85, 0.1,  0.1)
const C_BLUE_BOX   := Color(0.1,  0.35, 0.85)
const C_CARD_BG    := Color(0.97, 0.97, 0.95)
const C_HEADER_BG  := Color(0.99, 0.99, 0.99)
const C_FOOTER_BG  := Color(0.92, 0.92, 0.92)
const C_TEXT       := Color(0.1,  0.1,  0.1)
const C_SP_BG      := Color(0.9,  0.85, 0.2)

# 棋子文字
const RED_CHARS   := ["帥","仕","相","傌","俥","炮","兵"]
const BLACK_CHARS := ["將","士","象","馬","車","包","卒"]

# 卡牌模式
enum CardMode { SUMMON, STRATEGY }

var _mode: CardMode = CardMode.SUMMON

# -- 召喚卡欄位 --
var _card_name:   String = "卡牌"
var _type_char:   String = "兵"
var _sp_cost:     int    = 1
var _movement:    String = ""
var _effect_text: String = "無"
var _morale:      int    = 5
var _summon_type: String = "summon"

# -- 謀略卡欄位 --
var _strat_name:        String = "謀略"
var _strat_sp_cost:     int    = 1
var _strat_effect_text: String = ""

# -- 選中狀態 --
var is_selected: bool = false
var can_afford:  bool = true 

# ── 召喚卡設定 ──────────────────────────────────────────────────────
func setup(card: SummonCardData) -> void:
	_mode       = CardMode.SUMMON
	_card_name  = card.card_name if card.card_name != "" else card.id
	_sp_cost    = card.sp_cost
	_morale     = card.morale_value

	# 棋子種類文字
	var type_idx = card.summon_type as int
	_type_char  = RED_CHARS[type_idx] if type_idx < RED_CHARS.size() else "?"
	_summon_type = "summon"

	# 走法說明（僅在有特殊走法時顯示）
	_movement = ""
	for eff in card.special_effects:
		var path = eff.get_script().resource_path.to_lower()
		if "movement" in path or "leap" in path:
			_movement = "特殊走法"
			break

	# 效果文字
	if card.special_effects.size() > 0:
		_effect_text = card.effect_description if card.effect_description != "" else "特殊效果"
	else:
		_effect_text = "無"

	queue_redraw()

# ── 謀略卡設定 ──────────────────────────────────────────────────────
func setup_strategy(card: StrategyCardData) -> void:
	_mode               = CardMode.STRATEGY
	_strat_name         = card.card_name if card.card_name != "" else card.id
	_strat_sp_cost      = card.sp_cost
	_strat_effect_text  = card.effect_description if card.effect_description != "" else "無效果說明"
	queue_redraw()

# ── 繪製分派 ────────────────────────────────────────────────────────
func _draw() -> void:
	if _mode == CardMode.STRATEGY:
		_draw_strategy()
	else:
		_draw_summon()
	
	# 繪製選中高亮框
	if is_selected:
		var highlight_color = Color.GREEN if can_afford else Color.RED
		# 繪製稍微大一點的外框
		draw_rect(Rect2(-4, -4, CARD_W + 8, CARD_H + 8), highlight_color, false, 4)
		# 繪製半透明遮罩
		draw_rect(Rect2(0, 0, CARD_W, CARD_H), highlight_color * Color(1,1,1,0.15))

# ── 繪製謀略卡（依 stragety_card_demo_v1.png）─────────────────────
func _draw_strategy() -> void:
	var font = ThemeDB.fallback_font

	# 卡片本體底色
	draw_rect(Rect2(0, 0, CARD_W, CARD_H), C_CARD_BG)
	draw_rect(Rect2(0, 0, CARD_W, CARD_H), C_BORDER, false, 2)

	# ── 頂欄：Name + SP 圓 ─────────────────────────────────────────
	var header_rect = Rect2(3, 3, CARD_W - 6, HEADER_H)
	draw_rect(header_rect, C_HEADER_BG)
	draw_rect(header_rect, C_BORDER, false, 1.0)

	# 卡名（置中）
	_draw_centered_text(font, _strat_name, Vector2(CARD_W * 0.5 - 10, 3 + HEADER_H * 0.5), 19, C_TEXT)

	# SP 圓（右上角）
	var sp_cx = CARD_W - 24.0
	var sp_cy = 3 + HEADER_H * 0.5
	draw_circle(Vector2(sp_cx, sp_cy), 18, C_BORDER)
	draw_circle(Vector2(sp_cx, sp_cy), 16, C_SP_BG)
	_draw_centered_text(font, str(_strat_sp_cost), Vector2(sp_cx, sp_cy), 18, C_TEXT)

	# ── 大圖區（紅邊框）─────────────────────────────────────────────
	var img_y = 3 + HEADER_H + 3
	var img_rect = Rect2(3, img_y, CARD_W - 6, IMAGE_H)
	
	# 繪製裝飾性內框
	draw_rect(img_rect, Color(0.92, 0.92, 0.88))
	draw_rect(img_rect, C_RED_BORDER, false, 2.5)
	draw_rect(img_rect.grow(-4), C_RED_BORDER, false, 0.5) # 裝飾細線

	# 繪製一個抽象的策略圖示 (卷軸感)
	var icon_center = img_rect.get_center()
	var sw := 40.0
	var sh := 50.0
	var scroll_rect = Rect2(icon_center.x - sw * 0.5, icon_center.y - sh * 0.5, sw, sh)
	draw_rect(scroll_rect, Color.WHITE)
	draw_rect(scroll_rect, Color(0.8, 0.6, 0.1), false, 2)
	for i in range(3):
		var line_y = scroll_rect.position.y + 12 + i * 10
		draw_line(Vector2(scroll_rect.position.x + 8, line_y), Vector2(scroll_rect.end.x - 8, line_y), Color(0.8, 0.6, 0.1), 1.5)

	# 圖區底部：黑框 STRATEGY 標籤
	var label_y = img_y + IMAGE_H - 12
	var strat_rect = Rect2(CARD_W * 0.5 - 45, label_y, 90, 24)
	draw_rect(strat_rect, C_TEXT)
	_draw_centered_text(font, "STRATEGY", Vector2(CARD_W * 0.5, label_y + 12), 12, Color.WHITE)

	# ── 效果區 ──────────────────────────────────────────────────────
	var eff_y = img_y + IMAGE_H + 8
	var eff_rect = Rect2(3, eff_y, CARD_W - 6, EFFECT_H)
	draw_rect(eff_rect, C_CARD_BG)
	draw_rect(eff_rect, C_RED_BORDER, false, 2)
	_draw_wrapped_text(font, _strat_effect_text, Rect2(10, eff_y + 8, CARD_W - 20, EFFECT_H - 16), 14, C_TEXT)

	# ── 底欄（灰色）─────────────────────────────────────────────────
	var footer_y = eff_y + EFFECT_H + 3
	draw_rect(Rect2(3, footer_y, CARD_W - 6, FOOTER_H), C_FOOTER_BG)
	draw_rect(Rect2(3, footer_y, CARD_W - 6, FOOTER_H), C_BORDER, false, 1.5)

# ── 繪製召喚卡（原有邏輯）──────────────────────────────────────────
func _draw_summon() -> void:
	var font = ThemeDB.fallback_font

	# ── 卡片本體底色 ───────────────────────────
	draw_rect(Rect2(0, 0, CARD_W, CARD_H), C_CARD_BG)
	draw_rect(Rect2(0, 0, CARD_W, CARD_H), C_BORDER, false, 2)

	# ── 頂欄（紅外框）─────────────────────────
	var header_rect = Rect2(3, 3, CARD_W - 6, HEADER_H)
	draw_rect(header_rect, C_HEADER_BG)
	draw_rect(header_rect, C_RED_BORDER, false, 2)

	var circle_offset = 24
	var outer_r = 17
	var inner_r = 14

	# 左圓（棋子種類）
	draw_circle(Vector2(circle_offset, 3 + HEADER_H * 0.5), outer_r, C_RED_BORDER)
	draw_circle(Vector2(circle_offset, 3 + HEADER_H * 0.5), inner_r, C_CARD_BG)
	_draw_centered_text(font, _type_char, Vector2(circle_offset, 3 + HEADER_H * 0.5), 16, C_RED_BORDER)

	# 卡名（中間）
	_draw_centered_text(font, _card_name, Vector2(CARD_W * 0.5, 3 + HEADER_H * 0.5), 18, C_TEXT)

	# 右圓（SP）
	draw_circle(Vector2(CARD_W - circle_offset, 3 + HEADER_H * 0.5), outer_r, C_SP_BG)
	draw_circle(Vector2(CARD_W - circle_offset, 3 + HEADER_H * 0.5), inner_r, C_CARD_BG)
	_draw_centered_text(font, str(_sp_cost), Vector2(CARD_W - circle_offset, 3 + HEADER_H * 0.5), 16, C_TEXT)

	# ── 大圖區（紅外框）────────────────────────
	var img_y = 3 + HEADER_H + 3
	var img_rect = Rect2(3, img_y, CARD_W - 6, IMAGE_H)
	draw_rect(img_rect, C_CARD_BG)
	draw_rect(img_rect, C_RED_BORDER, false, 2)

	# 棋子文字預覽（置中大字）
	_draw_centered_text(font, _type_char, Vector2(CARD_W * 0.5, img_y + IMAGE_H * 0.5), 48, C_RED_BORDER)

	# 圖區底部：黑框 summon + 藍框 Movement
	var label_y = img_y + IMAGE_H - 30
	var summon_rect = Rect2(24, label_y, 64, 24)
	draw_rect(summon_rect, C_CARD_BG)
	draw_rect(summon_rect, C_BORDER, false, 2)
	_draw_centered_text(font, _summon_type, Vector2(56, label_y + 12), 15, C_TEXT)

	if _movement != "":
		var move_rect = Rect2(98, label_y - 12, 60, 38)
		draw_rect(move_rect, C_CARD_BG)
		draw_rect(move_rect, C_BLUE_BOX, false, 2)
		_draw_centered_text(font, _movement, Vector2(128, label_y + 7), 13, C_BLUE_BOX)

	# ── 效果區 ──────────────────────────────────
	var eff_y = img_y + IMAGE_H + 4
	draw_rect(Rect2(3, eff_y, CARD_W - 6, EFFECT_H), C_CARD_BG)
	draw_rect(Rect2(3, eff_y, CARD_W - 6, EFFECT_H), C_BORDER, false, 1.5)
	_draw_wrapped_text(font, "Effect: " + _effect_text, Rect2(8, eff_y + 6, CARD_W - 16, EFFECT_H - 12), 14, C_TEXT)

	# ── 底欄（士氣）────────────────────────────
	var footer_y = eff_y + EFFECT_H + 3
	draw_rect(Rect2(3, footer_y, CARD_W - 6, FOOTER_H), C_FOOTER_BG)
	draw_rect(Rect2(3, footer_y, CARD_W - 6, FOOTER_H), C_BORDER, false, 1.5)
	_draw_centered_text(font, "Morale: %d" % _morale, Vector2(CARD_W * 0.5, footer_y + FOOTER_H * 0.5), 18, C_TEXT)

## 文字垂直+水平置中繪製
func _draw_centered_text(font: Font, text: String, center: Vector2, size: int, color: Color) -> void:
	var tw = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var ascent = font.get_ascent(size)
	var th = font.get_height(size)
	draw_string(font, center + Vector2(-tw * 0.5, ascent - th * 0.5), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

## 簡易換行文字（超寬時換行）
func _draw_wrapped_text(font: Font, text: String, rect: Rect2, size: int, color: Color) -> void:
	var line_h = font.get_height(size) + 2
	var words = text.split(" ")
	var line = ""
	var y = rect.position.y + font.get_ascent(size)
	for word in words:
		var test = (line + " " + word).strip_edges()
		if font.get_string_size(test, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > rect.size.x:
			draw_string(font, Vector2(rect.position.x, y), line, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
			line = word
			y += line_h
			if y > rect.position.y + rect.size.y:
				break
		else:
			line = test
	if line != "" and y <= rect.position.y + rect.size.y:
		draw_string(font, Vector2(rect.position.x, y), line, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)
