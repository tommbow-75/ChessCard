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

const PieceViewScript    = preload("res://src/ui/PieceView.gd")
const LobbyPanelScript   = preload("res://src/ui/LobbyPanel.gd")

func _ready() -> void:
	game = XiangqiGame.new()
	game.setup_standard_board()
	_rebuild_pieces()

	if not $BoardRenderer or not $PiecesLayer or not $CardHandPanel or not $HUD:
		printerr("錯誤：部分 UI 節點未被正確參考！")
	_update_hud()
	# 連接重新開始信號
	if hud and hud.has_signal("restart_requested"):
		hud.restart_requested.connect(restart_game)
	# 開始前先顯示牌庫設定界面
	_show_lobby()

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
				# 如果是 AREA_3X3 模式，顯示周圍 3x3 預覽
				var first_eff = targeting_strategy.special_effects[0] if targeting_strategy.special_effects.size() > 0 else null
				if first_eff != null and first_eff is StrategyEffectTiming and \
						first_eff.target_mode == StrategyEffectTiming.TargetMode.AREA_3X3:
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
				refresh_hand()
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
			refresh_hand()
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
# 手牌面板更新
# ──────────────────────────────────────────────
func refresh_hand() -> void:
	if card_hand_panel == null:
		return
	var deck = game.deck_red if game.current_turn == XiangqiPiece.Side.RED else game.deck_black
	var hand: Array = []
	for c in deck.get_hand():
		hand.append(c)
	card_hand_panel.set_hand(hand)

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
# 牌庫設定界面 (Lobby)
# ──────────────────────────────────────────────
func _show_lobby() -> void:
	var lobby = LobbyPanelScript.new()
	add_child(lobby)
	lobby.game_start_requested.connect(_on_game_start)

func _on_game_start(deck_red_cards: Array, deck_black_cards: Array) -> void:
	game.deck_red.unlock()
	game.deck_black.unlock()
	if not game.deck_red.build_deck(deck_red_cards):
		printerr("[GameUI] 紅方牌庫驗證失敗")
		return
	if not game.deck_black.build_deck(deck_black_cards):
		printerr("[GameUI] 黑方牌庫驗證失敗")
		return
	refresh_hand()

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
	queue_redraw()
	# 重新顯示牌庫設定界面
	_show_lobby()
