extends Node2D

## 象棋主控制器
## 整合 XiangqiGame 核心邏輯，處理滑鼠點選、棋子選取、走子、回合切換
## 並顯示 SP / 士氣 HUD，以及 CHECK 提示

const BOARD_OFFSET := Vector2(50, 50)
const CELL_SIZE    := 70

# CHECK 文字顯示在棋盤右側的 X 座標
const CHECK_X := 700.0

@onready var board_renderer: Node2D = $BoardRenderer
@onready var pieces_layer:   Node2D = $PiecesLayer
@onready var hint_overlay:   Node2D = $HintOverlay
@onready var hud: Node         = $HUD
@onready var card_hand_panel: Node2D = $CardHandPanel

var game: XiangqiGame
var selected_pos := Vector2i(-1, -1)
var piece_views: Dictionary = {}
var red_in_check:   bool = false
var black_in_check: bool = false

var targeting_strategy: StrategyCardData = null
var valid_strategy_targets: Array[Vector2i] = []
var hovered_pos := Vector2i(-1, -1)

const PieceViewScript = preload("res://src/ui/PieceView.gd")

func _ready() -> void:
	game = XiangqiGame.new()
	game.setup_standard_board()
	_rebuild_pieces()
	
	if not $BoardRenderer or not $PiecesLayer or not $CardHandPanel or not $HUD:
		printerr("錯誤：部分 UI 節點未被正確參考！")
	_update_hud()
	_setup_demo_hand()
	# 連接重新開始信號
	if hud and hud.has_signal("restart_requested"):
		hud.restart_requested.connect(restart_game)

func _input(event: InputEvent):
	if game.is_game_over:
		return
		
	if event is InputEventMouseMotion:
		var local_pos = get_local_mouse_position()
		var grid = _screen_to_board(local_pos)
		if _is_valid_grid(grid) and targeting_strategy != null:
			if hovered_pos != grid:
				hovered_pos = grid
				
				var h_poses: Array[Vector2i] = [grid]
				# 如果是範圍攻擊 (如巨石)，顯示 3x3 預覽
				if targeting_strategy.id == "巨石":
					for dx in range(-1, 2):
						for dy in range(-1, 2):
							if dx == 0 and dy == 0: continue
							h_poses.append(Vector2i(grid.x + dx, grid.y + dy))
				
				hint_overlay.strategy_hover_poses = h_poses
				hint_overlay.queue_redraw()
		else:
			if hovered_pos != Vector2i(-1, -1):
				hovered_pos = Vector2i(-1, -1)
				hint_overlay.strategy_hover_poses.clear()
				hint_overlay.queue_redraw()

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_pos = get_local_mouse_position()
		var grid = _screen_to_board(local_pos)
		if _is_valid_grid(grid):
			_handle_click(grid)

# ──────────────────────────────────────────────
# 點擊邏輯
# ──────────────────────────────────────────────
func _handle_click(grid: Vector2i):
	if targeting_strategy != null:
		if grid in valid_strategy_targets:
			if game.play_strategy_card(targeting_strategy, grid):
				targeting_strategy = null
				valid_strategy_targets.clear()
				hint_overlay.strategy_targets.clear()
				hint_overlay.all_piece_pos.clear()
				hint_overlay.is_targeting = false
				hint_overlay.strategy_hover_poses.clear()
				hint_overlay.queue_redraw()
				_rebuild_pieces()
				_update_check_state()
				_update_hud()
		else:
			targeting_strategy = null
			valid_strategy_targets.clear()
			hint_overlay.strategy_targets.clear()
			hint_overlay.all_piece_pos.clear()
			hint_overlay.is_targeting = false
			hint_overlay.strategy_hover_poses.clear()
			hint_overlay.queue_redraw()
		return

	var piece = game.board.get_piece(grid)

	# 點自己陣營且未暈眩的棋子 → 選取
	if piece != null and piece.side == game.current_turn and not piece.is_stunned:
		selected_pos = grid
		_update_hints()
		return

	# 已有選取 → 嘗試走子
	if selected_pos != Vector2i(-1, -1):
		var moved = game.move_piece(selected_pos, grid)
		if moved:
			selected_pos = Vector2i(-1, -1)
			_update_hints()
			_rebuild_pieces()
			_update_check_state()
			_update_hud()
			queue_redraw()
			return

	# 點空格或點到敵方但沒選子 → 取消選取
	selected_pos = Vector2i(-1, -1)
	_update_hints()

# ──────────────────────────────────────────────
# CHECK 偵測：移動後偵測雙方 check 狀態
# ──────────────────────────────────────────────
func _update_check_state() -> void:
	red_in_check   = game.is_in_check(XiangqiPiece.Side.RED)
	black_in_check = game.is_in_check(XiangqiPiece.Side.BLACK)

# ──────────────────────────────────────────────
# 繪製 CHECK 文字（棋盤右側）
# ──────────────────────────────────────────────
func _draw() -> void:
	if game == null:
		return

	var font = ThemeDB.fallback_font
	var font_size = 28

	# 黑方 CHECK（棋盤上方，對應 row 0 附近）
	if black_in_check:
		var pos = Vector2(CHECK_X, BOARD_OFFSET.y + 0 * CELL_SIZE)
		_draw_check_label(font, font_size, "⚠ CHECK！", pos, Color(0.1, 0.1, 0.1))

	# 紅方 CHECK（棋盤下方，對應 row 9 附近）
	if red_in_check:
		var pos = Vector2(CHECK_X, BOARD_OFFSET.y + 9 * CELL_SIZE)
		_draw_check_label(font, font_size, "⚠ CHECK！", pos, Color(0.85, 0.1, 0.1))

func _draw_check_label(font: Font, font_size: int, text: String, pos: Vector2, color: Color) -> void:
	# 背景
	var tw = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var th = font.get_height(font_size)
	draw_rect(Rect2(pos.x - 4, pos.y - th * 0.5 - 2, tw + 8, th + 4), Color(1, 1, 0.8, 0.85))
	draw_rect(Rect2(pos.x - 4, pos.y - th * 0.5 - 2, tw + 8, th + 4), color, false, 2)
	# 文字
	draw_string(font, Vector2(pos.x, pos.y + font.get_ascent(font_size) - th * 0.5), text,
		HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

# ──────────────────────────────────────────────
# 合法走步提示（分離走步 / 吃子）
# ──────────────────────────────────────────────
func _update_hints():
	board_renderer.selected_pos = selected_pos
	board_renderer.hint_positions.clear()
	hint_overlay.capture_positions.clear()

	if selected_pos != Vector2i(-1, -1):
		for y in range(10):
			for x in range(9):
				var to = Vector2i(x, y)
				if XiangqiRuleVerifier.is_valid_move(game.board, selected_pos, to):
					if game.board.has_piece(to):
						hint_overlay.capture_positions.append(to)
					else:
						board_renderer.hint_positions.append(to)

	board_renderer.queue_redraw()
	hint_overlay.queue_redraw()

# ──────────────────────────────────────────────
# 重建棋子視覺
# ──────────────────────────────────────────────
func _rebuild_pieces():
	for child in pieces_layer.get_children():
		child.queue_free()
	piece_views.clear()

	for pos in game.board.pieces:
		var piece = game.board.pieces[pos]
		var view = PieceViewScript.new()
		pieces_layer.add_child(view)
		view.setup(piece, pos, BOARD_OFFSET)
		piece_views[pos] = view

# ──────────────────────────────────────────────
# HUD 更新（含 SP、士氣）
# ──────────────────────────────────────────────
func _update_hud():
	if hud == null:
		return
	hud.update_state(
		game.current_turn,
		game.is_game_over,
		game.winner,
		game.sp_red,
		game.sp_black,
		game.morale_red,
		game.morale_black
	)

# ──────────────────────────────────────────────
# 示範用手牌（test data，之後由遊戲系統替換）
# ──────────────────────────────────────────────
func _setup_demo_hand() -> void:
	if card_hand_panel == null:
		return
	var cards: Array = []

	var _make_card = func(id: String, cname: String, sp: int, morale: int, type: int, effect: String) -> SummonCardData:
		var c = SummonCardData.new()
		c.id = id
		c.card_name = cname
		c.sp_cost = sp
		c.morale_value = morale
		c.summon_type = type
		c.effect_description = effect	
		return c
		
	var my_card = preload("res://Resources/SummonCard/Soldier/mercenary_soldier.tres")

	cards.append(my_card)
	cards.append(_make_card.call("basic_soldier", "基礎兵", 1, 5, 6, "無"))
	cards.append(_make_card.call("doctor_elephant", "醫生象", 3, 10, 2, "召喚：+5 士氣"))
	cards.append(_make_card.call("trash_cannon", "垃圾炮", 2, 5, 5, "天生：不可吃將"))
	cards.append(_make_card.call("flame_chariot", "火焰車", 3, 15, 3, "一次：吃後再走"))

	card_hand_panel.set_hand(cards)
	
	# 加入謀略卡測試按鈕
	var vbox = VBoxContainer.new()
	vbox.position = Vector2(800, 10)
	add_child(vbox)
	
	var test_label = Label.new()
	test_label.text = "謀略卡測試區"
	test_label.add_theme_color_override("font_color", Color(0,0,0))
	vbox.add_child(test_label)
	
	_create_test_button(vbox, "能量射擊", 2, RemovePieceEffect.new(), StragetyEffect.TargetType.SINGLE_ENEMY_NON_GENERAL)
	_create_test_button(vbox, "鼓舞", 1, HealMoraleEffect.new(), StragetyEffect.TargetType.NONE)
	_create_test_button(vbox, "思考", 1, DrawCardEffect.new(), StragetyEffect.TargetType.NONE)
	
	var b_eff = RemovePieceEffect.new()
	b_eff.target_type = StragetyEffect.TargetType.AREA_3X3_ANY
	_create_test_button(vbox, "巨石", 6, b_eff, StragetyEffect.TargetType.AREA_3X3_ANY)
	
	var st_eff = StunEffect.new()
	_create_test_button(vbox, "暈眩", 3, st_eff, StragetyEffect.TargetType.SINGLE_ENEMY_NON_GENERAL)
	
	var di_eff = DiscountMoraleEffect.new()
	_create_test_button(vbox, "威脅", 3, di_eff, StragetyEffect.TargetType.NONE)
	
	var hm_eff = TurnIntoEffect.new()
	hm_eff.behavior = TurnIntoEffect.TransformTarget.ANY_NON_GENERAL_TO_HORSE
	_create_test_button(vbox, "上馬", 2, hm_eff, StragetyEffect.TargetType.ANY_NON_GENERAL)
	
	var md_eff = TurnIntoEffect.new()
	md_eff.behavior = TurnIntoEffect.TransformTarget.ANY_SOLDIER_TO_CHARIOT
	_create_test_button(vbox, "機械化", 3, md_eff, StragetyEffect.TargetType.ANY_SOLDIER)
	
	var rb_eff = TurnIntoEffect.new()
	rb_eff.behavior = TurnIntoEffect.TransformTarget.ENEMY_NON_GENERAL_TO_ALLY
	_create_test_button(vbox, "策反", 5, rb_eff, StragetyEffect.TargetType.SINGLE_ENEMY_NON_GENERAL)
	
	var mr_eff = MoveRightnowEffect.new()
	_create_test_button(vbox, "調度", 5, mr_eff, StragetyEffect.TargetType.NONE)

func _create_test_button(parent: Control, c_name: String, sp: int, effect: StragetyEffect, target_type: int):
	var btn = Button.new()
	btn.text = c_name + " (" + str(sp) + "SP)"
	btn.pressed.connect(func():
		_test_play_strategy(c_name, sp, effect, target_type)
	)
	parent.add_child(btn)

func _test_play_strategy(c_name: String, sp: int, effect: StragetyEffect, target_type: int):
	targeting_strategy = null
	valid_strategy_targets.clear()
	hint_overlay.strategy_targets.clear()
	hint_overlay.all_piece_pos.clear()
	hint_overlay.is_targeting = false
	hint_overlay.strategy_hover_poses.clear()
	hint_overlay.queue_redraw()
	
	var card = StrategyCardData.new()
	card.id = c_name
	card.card_name = c_name
	card.sp_cost = sp
	effect.target_type = target_type
	card.special_effects.append(effect)
	
	var current_sp = game.sp_red if game.current_turn == XiangqiPiece.Side.RED else game.sp_black
	if current_sp < sp:
		print("SP 不足！無法發動 ", c_name)
		return
		
	if target_type == StragetyEffect.TargetType.NONE:
		if game.play_strategy_card(card):
			print("打出謀略卡：" + c_name)
			_rebuild_pieces()
			_update_check_state()
			_update_hud()
	else:
		targeting_strategy = card
		valid_strategy_targets = game.get_valid_strategy_targets(card)
		hint_overlay.strategy_targets = valid_strategy_targets
		var typed_keys: Array[Vector2i] = []
		for p in game.board.pieces:
			typed_keys.append(p)
		hint_overlay.all_piece_pos = typed_keys
		hint_overlay.is_targeting = true
		hint_overlay.queue_redraw()
		print("請選擇目標 (" + c_name + ")")

# ──────────────────────────────────────────────
# 座標轉換
# ──────────────────────────────────────────────
func _screen_to_board(screen_pos: Vector2) -> Vector2i:
	var rel = screen_pos - BOARD_OFFSET
	var gx = roundi(rel.x / CELL_SIZE)
	var gy = roundi(rel.y / CELL_SIZE)
	return Vector2i(gx, gy)

func _is_valid_grid(grid: Vector2i) -> bool:
	return grid.x >= 0 and grid.x <= 8 and grid.y >= 0 and grid.y <= 9

# ──────────────────────────────────────────────
# 重新開始（由 HUD 按鈕呼叫）
# ──────────────────────────────────────────────
func restart_game():
	game.setup_standard_board()
	selected_pos = Vector2i(-1, -1)
	red_in_check = false
	black_in_check = false
	_update_hints()
	_rebuild_pieces()
	_update_hud()
	_setup_demo_hand()
	queue_redraw()
