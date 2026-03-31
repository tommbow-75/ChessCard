extends CanvasLayer

## LobbyPanel：遊戲開始前的牌庫設定介面
## - 雙方各可從卡牌池加入最多 30 張卡（相同 ID ≤ 2）
## - 點「鎖定」後牌庫確定，不可更動
## - 雙方皆鎖定後「開始遊戲」按鈕啟用

signal game_start_requested(deck_red: Array, deck_black: Array)

const MAX_DECK  := 30
const MAX_COPY  := 2

## 卡池：從 res://Resources/ 動態載入的所有卡牌
var _card_pool: Array = []

## 雙方牌組 {id -> Array[CardData]}
var _deck_red:   Dictionary = {}
var _deck_black: Dictionary = {}

var _locked_red:   bool = false
var _locked_black: bool = false

# ── UI 節點參考 ──────────────────────────────────────────────────────
var _panel:            ColorRect
var _pool_vbox:        VBoxContainer
var _red_vbox:         VBoxContainer
var _black_vbox:       VBoxContainer
var _red_count_label:  Label
var _black_count_label: Label
var _red_lock_btn:     Button
var _black_lock_btn:   Button
var _start_btn:        Button

const C_BG        := Color(0.12, 0.12, 0.16, 0.97)
const C_PANEL     := Color(0.18, 0.18, 0.24)
const C_RED_SIDE  := Color(0.55, 0.1,  0.1,  0.85)
const C_BLK_SIDE  := Color(0.12, 0.12, 0.12, 0.85)
const C_POOL_BG   := Color(0.2,  0.2,  0.28, 0.9)
const C_LOCKED    := Color(0.2,  0.6,  0.2)
const C_START_ON  := Color(0.25, 0.6,  0.25)
const C_START_OFF := Color(0.35, 0.35, 0.35)

func _ready() -> void:
	_load_card_pool()
	_build_ui()
	_refresh_pool_list()

# ── 卡池載入 ────────────────────────────────────────────────────────
func _load_card_pool() -> void:
	var dirs = [
		"res://Resources/SummonCard",
		"res://Resources/StrategyCard",
	]
	for dir_path in dirs:
		var dir = DirAccess.open(dir_path)
		if dir == null:
			continue
		dir.list_dir_begin()
		var sub = dir.get_next()
		while sub != "":
			if dir.current_is_dir() and not sub.begins_with("."):
				var sub_dir = DirAccess.open(dir_path + "/" + sub)
				if sub_dir:
					sub_dir.list_dir_begin()
					var file = sub_dir.get_next()
					while file != "":
						if file.ends_with(".tres"):
							var res = load(dir_path + "/" + sub + "/" + file)
							if res is CardData and res.id != "":
								_card_pool.append(res)
						file = sub_dir.get_next()
					sub_dir.list_dir_end()
			sub = dir.get_next()
		dir.list_dir_end()

# ── UI 建立 ─────────────────────────────────────────────────────────
func _build_ui() -> void:
	# 全螢幕黑底
	_panel = ColorRect.new()
	_panel.color = C_BG
	_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_panel)

	# 標題
	var title = Label.new()
	title.text = "🎴  牌庫設定"
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color(1, 0.9, 0.5))
	title.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 18
	title.offset_bottom = 60
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_panel.add_child(title)

	# 三欄容器
	var hbox = HBoxContainer.new()
	hbox.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hbox.offset_top    = 70
	hbox.offset_bottom = -70
	hbox.offset_left   = 20
	hbox.offset_right  = -20
	hbox.add_theme_constant_override("separation", 14)
	_panel.add_child(hbox)

	# 紅方欄
	var red_col = _make_side_column("🔴 紅方牌庫", C_RED_SIDE)
	hbox.add_child(red_col["root"])
	_red_vbox         = red_col["vbox"]
	_red_count_label  = red_col["count"]
	_red_lock_btn     = red_col["lock"]
	_red_lock_btn.pressed.connect(_on_lock_red)

	# 卡池欄
	var pool_col = _make_pool_column()
	hbox.add_child(pool_col["root"])
	_pool_vbox = pool_col["vbox"]

	# 黑方欄
	var blk_col = _make_side_column("⚫ 黑方牌庫", C_BLK_SIDE)
	hbox.add_child(blk_col["root"])
	_black_vbox         = blk_col["vbox"]
	_black_count_label  = blk_col["count"]
	_black_lock_btn     = blk_col["lock"]
	_black_lock_btn.pressed.connect(_on_lock_black)

	# 開始遊戲按鈕（底部）
	_start_btn = Button.new()
	_start_btn.text = "▶  開始遊戲"
	_start_btn.add_theme_font_size_override("font_size", 22)
	_start_btn.disabled = true
	_start_btn.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	_start_btn.offset_top    = -60
	_start_btn.offset_bottom = -10
	_start_btn.offset_left   = 200
	_start_btn.offset_right  = -200
	_start_btn.pressed.connect(_on_start_game)
	_panel.add_child(_start_btn)

func _make_side_column(title_text: String, header_color: Color) -> Dictionary:
	var root = PanelContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_stretch_ratio = 1.0

	var vb_outer = VBoxContainer.new()
	vb_outer.size_flags_horizontal = Control.SIZE_FILL
	root.add_child(vb_outer)

	# 標題
	var hdr = ColorRect.new()
	hdr.color = header_color
	hdr.custom_minimum_size = Vector2(0, 36)
	vb_outer.add_child(hdr)
	var hdr_label = Label.new()
	hdr_label.text = title_text
	hdr_label.add_theme_font_size_override("font_size", 17)
	hdr_label.add_theme_color_override("font_color", Color.WHITE)
	hdr_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hdr_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hdr.add_child(hdr_label)

	# 張數
	var count_lbl = Label.new()
	count_lbl.text = "0 / 30"
	count_lbl.add_theme_font_size_override("font_size", 14)
	count_lbl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	count_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb_outer.add_child(count_lbl)

	# 卡牌列表（scrollable）
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vb_outer.add_child(scroll)

	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 4)
	scroll.add_child(vbox)

	# 鎖定按鈕
	var lock_btn = Button.new()
	lock_btn.text = "🔒  鎖定牌庫"
	lock_btn.add_theme_font_size_override("font_size", 15)
	vb_outer.add_child(lock_btn)

	return {"root": root, "vbox": vbox, "count": count_lbl, "lock": lock_btn}

func _make_pool_column() -> Dictionary:
	var root = PanelContainer.new()
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	root.size_flags_stretch_ratio = 1.0

	var vb = VBoxContainer.new()
	root.add_child(vb)

	var hdr = ColorRect.new()
	hdr.color = C_POOL_BG
	hdr.custom_minimum_size = Vector2(0, 36)
	vb.add_child(hdr)
	var hdr_l = Label.new()
	hdr_l.text = "📦  可用卡牌"
	hdr_l.add_theme_font_size_override("font_size", 17)
	hdr_l.add_theme_color_override("font_color", Color(0.9, 0.9, 1.0))
	hdr_l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hdr_l.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hdr.add_child(hdr_l)

	var hint = Label.new()
	hint.text = "點 [紅+] / [黑+] 加入對應牌庫"
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color(0.6, 0.8, 0.6))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(hint)

	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vb.add_child(scroll)

	var vbox = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_theme_constant_override("separation", 6)
	scroll.add_child(vbox)

	return {"root": root, "vbox": vbox}

# ── 卡池刷新 ─────────────────────────────────────────────────────────
func _refresh_pool_list() -> void:
	for child in _pool_vbox.get_children():
		child.queue_free()

	for card in _card_pool:
		var row = HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)

		var lbl = Label.new()
		var tag = "[召喚]" if card is SummonCardData else "[謀略]"
		lbl.text = "%s %s  (SP:%d)" % [tag, card.card_name if card.card_name != "" else card.id, card.sp_cost]
		lbl.add_theme_font_size_override("font_size", 13)
		lbl.add_theme_color_override("font_color", Color.WHITE)
		lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		row.add_child(lbl)

		var btn_r = Button.new()
		btn_r.text = "紅+"
		btn_r.add_theme_font_size_override("font_size", 12)
		btn_r.add_theme_color_override("font_color", Color(1, 0.4, 0.4))
		btn_r.pressed.connect(_add_to_deck.bind(card, true))
		row.add_child(btn_r)

		var btn_b = Button.new()
		btn_b.text = "黑+"
		btn_b.add_theme_font_size_override("font_size", 12)
		btn_b.add_theme_color_override("font_color", Color(0.5, 0.8, 1.0))
		btn_b.pressed.connect(_add_to_deck.bind(card, false))
		row.add_child(btn_b)

		_pool_vbox.add_child(row)

# ── 加入牌庫 ─────────────────────────────────────────────────────────
func _add_to_deck(card: CardData, is_red: bool) -> void:
	if is_red and _locked_red:   return
	if not is_red and _locked_black: return

	var deck = _deck_red if is_red else _deck_black
	var total = _count_deck(deck)
	if total >= MAX_DECK:
		return

	var copies = deck.get(card.id, [])
	if copies.size() >= MAX_COPY:
		return

	copies.append(card)
	deck[card.id] = copies
	_refresh_side(is_red)
	_update_start_btn()

# ── 移除一張 ─────────────────────────────────────────────────────────
func _remove_from_deck(card_id: String, is_red: bool) -> void:
	var deck = _deck_red if is_red else _deck_black
	if not deck.has(card_id):
		return
	var copies: Array = deck[card_id]
	copies.pop_back()
	if copies.is_empty():
		deck.erase(card_id)
	else:
		deck[card_id] = copies
	_refresh_side(is_red)
	_update_start_btn()

# ── 刷新單方牌庫列表 ─────────────────────────────────────────────────
func _refresh_side(is_red: bool) -> void:
	var vbox  = _red_vbox   if is_red else _black_vbox
	var lbl   = _red_count_label if is_red else _black_count_label
	var deck  = _deck_red   if is_red else _deck_black
	var locked = _locked_red if is_red else _locked_black

	for child in vbox.get_children():
		child.queue_free()

	var total = _count_deck(deck)
	lbl.text = "%d / %d" % [total, MAX_DECK]
	lbl.add_theme_color_override("font_color",
		Color(0.3, 1.0, 0.3) if total == MAX_DECK else Color(0.8, 0.8, 0.8))

	for id in deck:
		var copies: Array = deck[id]
		for c in copies:
			var row = HBoxContainer.new()
			var name_lbl = Label.new()
			name_lbl.text = "[%s] %s" % [("召喚" if c is SummonCardData else "謀略"),
				c.card_name if c.card_name != "" else c.id]
			name_lbl.add_theme_font_size_override("font_size", 12)
			name_lbl.add_theme_color_override("font_color", Color.WHITE)
			name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(name_lbl)

			if not locked:
				var rm_btn = Button.new()
				rm_btn.text = "✕"
				rm_btn.add_theme_font_size_override("font_size", 12)
				rm_btn.pressed.connect(_remove_from_deck.bind(id, is_red))
				row.add_child(rm_btn)

			vbox.add_child(row)

# ── 鎖定 ─────────────────────────────────────────────────────────────
func _on_lock_red() -> void:
	if _count_deck(_deck_red) != MAX_DECK:
		# 顯示錯誤提示
		_show_tip("紅方牌庫需達 30 張才能鎖定（目前 %d 張）" % _count_deck(_deck_red))
		return
	_locked_red = true
	_red_lock_btn.text = "✅ 已鎖定"
	_red_lock_btn.disabled = true
	_red_lock_btn.add_theme_color_override("font_color", C_LOCKED)
	_refresh_side(true)
	_update_start_btn()

func _on_lock_black() -> void:
	if _count_deck(_deck_black) != MAX_DECK:
		_show_tip("黑方牌庫需達 30 張才能鎖定（目前 %d 張）" % _count_deck(_deck_black))
		return
	_locked_black = true
	_black_lock_btn.text = "✅ 已鎖定"
	_black_lock_btn.disabled = true
	_black_lock_btn.add_theme_color_override("font_color", C_LOCKED)
	_refresh_side(false)
	_update_start_btn()

func _update_start_btn() -> void:
	_start_btn.disabled = not (_locked_red and _locked_black)

# ── 開始遊戲 ───────────────────────────────────────────────────────────
func _on_start_game() -> void:
	var flat_red: Array = []
	for id in _deck_red:
		for c in _deck_red[id]:
			flat_red.append(c)

	var flat_black: Array = []
	for id in _deck_black:
		for c in _deck_black[id]:
			flat_black.append(c)

	emit_signal("game_start_requested", flat_red, flat_black)
	queue_free()

# ── 輔助 ─────────────────────────────────────────────────────────────
func _count_deck(deck: Dictionary) -> int:
	var total := 0
	for id in deck:
		total += (deck[id] as Array).size()
	return total

func _show_tip(msg: String) -> void:
	# 簡易浮動提示 label
	var tip = Label.new()
	tip.text = " ⚠ " + msg + " "
	tip.add_theme_font_size_override("font_size", 15)
	tip.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	tip.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	tip.offset_top    = 60
	tip.offset_bottom = 92
	tip.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_panel.add_child(tip)
	# 2 秒後消失
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(tip.queue_free)
