extends Node2D

const BOARD_OFFSET := Vector2(50, 50)
const CELL_SIZE := 70
const CHECK_X := 700.0

@onready var board_renderer: Node2D = $BoardRenderer
@onready var pieces_layer: Node2D = $PiecesLayer
@onready var hint_overlay: Node2D = $HintOverlay
@onready var hud: CanvasLayer = $HUD
@onready var card_hand_panel: Node2D = $CardHandPanel

var game: XiangqiGame
var selected_pos := Vector2i(-1, -1)
var piece_views: Dictionary = {}
var red_in_check: bool = false
var black_in_check: bool = false

var targeting_card: CardData = null
var valid_card_targets: Array[Vector2i] = []
var hovered_pos := Vector2i(-1, -1)

const PieceViewScript = preload("res://src/ui/PieceView.gd")
const LobbyPanelScript = preload("res://src/ui/LobbyPanel.gd")


func _ready() -> void:
	game = XiangqiGame.new()
	game.setup_standard_board()
	_rebuild_pieces()

	if not $BoardRenderer or not $PiecesLayer or not $CardHandPanel or not $HUD:
		printerr("[GameUI] Missing required child nodes")

	_update_hud()
	if hud and hud.has_signal("restart_requested"):
		hud.restart_requested.connect(restart_game)
	if hud and hud.has_signal("end_turn_requested"):
		hud.end_turn_requested.connect(_on_end_turn_requested)

	if card_hand_panel:
		card_hand_panel.card_played.connect(_on_card_played)

	_show_lobby()

func _input(event: InputEvent) -> void:
	if game.is_game_over:
		return

	# ── ESC：取消浮框 ─────────────────────────────────
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if hint_overlay.once_popup_visible:
			_close_once_popup()
			return

	# ── 滑鼠移動：謀略卡 hover（浮框不隨 hover 開關）──
	if event is InputEventMouseMotion:
		var local_pos = get_local_mouse_position()
		var grid = _screen_to_board(local_pos)
		if _is_valid_grid(grid) and targeting_card != null:
			if hovered_pos != grid:
				hovered_pos = grid
				var hover_poses: Array[Vector2i] = [grid]
				if targeting_card is StrategyCardData:
					var first_eff = targeting_card.special_effects[0] if targeting_card.special_effects.size() > 0 else null
					if first_eff != null and first_eff is StrategyEffectTiming \
							and first_eff.target_mode != null \
							and first_eff.target_mode.mode == TargetMode.Mode.AREA_3X3:
						for dx in range(-1, 2):
							for dy in range(-1, 2):
								if dx == 0 and dy == 0:
									continue
								hover_poses.append(Vector2i(grid.x + dx, grid.y + dy))
				hint_overlay.strategy_hover_poses.assign(hover_poses)
				hint_overlay.queue_redraw()
		else:
			if hovered_pos != Vector2i(-1, -1):
				hovered_pos = Vector2i(-1, -1)
				hint_overlay.set("strategy_hover_poses", [])
				hint_overlay.queue_redraw()

	# ── 滑鼠左鍵 ─────────────────────────────────────
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_pos = get_local_mouse_position()

		# ── 優先：ONCE 浮框已鎖定時的按鈕 hit-test ──────
		if hint_overlay.once_popup_visible:
			if hint_overlay.once_activate_btn_rect.has_point(local_pos):
				_on_once_activate_clicked()
				return
			if hint_overlay.once_cancel_btn_rect.has_point(local_pos):
				_close_once_popup()
				return
			# 點擊浮框以外 → 關閉，不穿透到棋盤
			if not hint_overlay.once_popup_rect.has_point(local_pos):
				_close_once_popup()
			return

		var grid = _screen_to_board(local_pos)
		if not _is_valid_grid(grid):
			return

		# ── 在無卡牌選取模式下，點擊 ONCE 棋子開啟浮框 ──
		if targeting_card == null:
			var once_poses := game.get_once_effect_pieces()
			if grid in once_poses:
				_open_once_popup(grid)
				return

		_handle_click(grid)

func _handle_click(grid: Vector2i) -> void:
	if targeting_card != null:
		if grid in valid_card_targets:
			if targeting_card is StrategyCardData:
				if game.play_strategy_card(targeting_card, grid):
					_clear_card_targeting()
					_rebuild_pieces()
					_update_check_state()
					_update_hud()
					refresh_hand()
					_refresh_once_highlights()
			elif targeting_card is SummonCardData:
				if game.summon_piece(targeting_card, grid, game.current_turn):
					_clear_card_targeting()
					_rebuild_pieces()
					_update_check_state()
					_update_hud()
					refresh_hand()
					_refresh_once_highlights()
		else:
			_clear_card_targeting()
		return

	if not game.can_take_move_action():
		selected_pos = Vector2i(-1, -1)
		_update_hints()
		return

	var piece = game.board.get_piece(grid)
	if game.pending_extra_move_from != Vector2i(-1, -1):
		if piece != null and piece.side == game.current_turn and not piece.is_stunned and grid != game.pending_extra_move_from:
			return

	if piece != null and piece.side == game.current_turn and not piece.is_stunned:
		selected_pos = grid
		_update_hints()
		return

	if selected_pos != Vector2i(-1, -1):
		var moved = game.move_piece(selected_pos, grid)
		if moved:
			selected_pos = Vector2i(-1, -1)
			_update_hints()
			_rebuild_pieces()
			_update_check_state()
			_update_hud()
			refresh_hand()
			_refresh_once_highlights()
			queue_redraw()
			return

	selected_pos = Vector2i(-1, -1)
	_update_hints()

func _update_check_state() -> void:
	red_in_check = game.is_in_check(XiangqiPiece.Side.RED)
	black_in_check = game.is_in_check(XiangqiPiece.Side.BLACK)

func _draw() -> void:
	if game == null:
		return

	var font = ThemeDB.fallback_font
	var font_size = 28

	if black_in_check:
		var black_pos = Vector2(CHECK_X, BOARD_OFFSET.y)
		_draw_check_label(font, font_size, "CHECK", black_pos, Color(0.1, 0.1, 0.1))

	if red_in_check:
		var red_pos = Vector2(CHECK_X, BOARD_OFFSET.y + 9 * CELL_SIZE)
		_draw_check_label(font, font_size, "CHECK", red_pos, Color(0.85, 0.1, 0.1))

func _draw_check_label(font: Font, font_size: int, text: String, pos: Vector2, color: Color) -> void:
	var tw = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var th = font.get_height(font_size)
	draw_rect(Rect2(pos.x - 4, pos.y - th * 0.5 - 2, tw + 8, th + 4), Color(1, 1, 0.8, 0.85))
	draw_rect(Rect2(pos.x - 4, pos.y - th * 0.5 - 2, tw + 8, th + 4), color, false, 2)
	draw_string(font, Vector2(pos.x, pos.y + font.get_ascent(font_size) - th * 0.5), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, color)

# ── ONCE 浮框管理 ─────────────────────────────────────

## 點擊棋子後開啟並鎖定浮框
func _open_once_popup(piece_pos: Vector2i) -> void:
	var piece := game.board.get_piece(piece_pos)
	if piece == null:
		return
	var lines: Array[String] = []
	for eff in piece.special_effects:
		if eff.timing == SummonEffectTiming.Timing.ONCE:
			lines.append(_get_effect_description(eff))
	if lines.is_empty():
		return

	hint_overlay.once_popup_grid_pos = piece_pos
	hint_overlay.once_popup_lines    = lines
	hint_overlay.once_popup_visible  = true
	hint_overlay.queue_redraw()

## 關閉浮框
func _close_once_popup() -> void:
	hint_overlay.once_popup_visible  = false
	hint_overlay.once_popup_grid_pos = Vector2i(-1, -1)
	hint_overlay.once_popup_lines.clear()
	hint_overlay.queue_redraw()

## 點擊「發動」按鈕
func _on_once_activate_clicked() -> void:
	var pos: Vector2i = hint_overlay.once_popup_grid_pos
	_close_once_popup()
	if game.activate_once_effects_on_piece(pos):
		_rebuild_pieces()
		_update_check_state()
		_update_hud()
		_refresh_once_highlights()
		queue_redraw()

## 根據效果類型回傳中文描述
func _get_effect_description(effect: SummonEffectTiming) -> String:
	if effect is ExtraMoveEffect:
		return "吃子後可額外移動一次"
	if effect is KnightLeapEffect:
		return "使用一次騎士跳躍（無視拐馬腳）"
	return "特殊一次性效果"

## 刷新 HintOverlay 上的 ONCE 效果綠圈高亮
func _refresh_once_highlights() -> void:
	hint_overlay.once_effect_positions.assign(game.get_once_effect_pieces())
	hint_overlay.queue_redraw()

# ── 棋盤與棋子 ────────────────────────────────────────

func _update_hints() -> void:
	board_renderer.selected_pos = selected_pos
	board_renderer.hint_positions.clear()
	hint_overlay.capture_positions.clear()

	if selected_pos != Vector2i(-1, -1):
		for y in range(10):
			for x in range(9):
				var to = Vector2i(x, y)
				if not XiangqiRuleVerifier.is_valid_move(game.board, selected_pos, to):
					continue
				var from_piece = game.board.get_piece(selected_pos)
				var dest_piece = game.board.get_piece(to)
				var would_capture = from_piece != null and dest_piece != null and dest_piece.side != from_piece.side
				if would_capture and game.is_pending_capture_forbidden(dest_piece):
					continue
				if would_capture:
					hint_overlay.capture_positions.append(to)
				else:
					board_renderer.hint_positions.append(to)

	board_renderer.queue_redraw()
	hint_overlay.queue_redraw()

func _rebuild_pieces() -> void:
	for child in pieces_layer.get_children():
		child.queue_free()
	piece_views.clear()

	for pos in game.board.pieces:
		var piece = game.board.pieces[pos]
		var view = PieceViewScript.new()
		pieces_layer.add_child(view)
		view.setup(piece, pos, BOARD_OFFSET)
		piece_views[pos] = view

# ── 手牌 ──────────────────────────────────────────────

func refresh_hand() -> void:
	if card_hand_panel == null:
		return
	var side = game.current_turn
	var deck = game.deck_red if side == XiangqiPiece.Side.RED else game.deck_black
	var sp   = game.sp_red if side == XiangqiPiece.Side.RED else game.sp_black

	var hand: Array = []
	for c in deck.get_hand():
		hand.append(c)
	card_hand_panel.set_hand(hand, sp)

func _on_card_played(card: CardData) -> void:
	if not game.can_play_card_action():
		return

	if card is StrategyCardData:
		var targets = game.get_valid_strategy_targets(card)
		if targets.is_empty():
			if game.play_strategy_card(card):
				_rebuild_pieces()
				_update_check_state()
				_update_hud()
				refresh_hand()
				_refresh_once_highlights()
		else:
			targeting_card = card
			valid_card_targets = targets
			hint_overlay.set("strategy_targets", valid_card_targets)
			hint_overlay.set("all_pieces_on_board", game.board.pieces.keys())
			hint_overlay.is_targeting = true
			hint_overlay.queue_redraw()
	elif card is SummonCardData:
		var targets = game.get_valid_summon_positions(card)
		if not targets.is_empty():
			targeting_card = card
			valid_card_targets = targets
			hint_overlay.set("strategy_targets", valid_card_targets)
			hint_overlay.set("all_pieces_on_board", game.board.pieces.keys())
			hint_overlay.is_targeting = true
			hint_overlay.queue_redraw()

# ── HUD ───────────────────────────────────────────────

func _update_hud() -> void:
	if hud == null or not hud.has_method("update_state"):
		return
	hud.call("update_state",
		game.current_turn,
		game.is_game_over,
		game.winner,
		game.sp_red,
		game.sp_black,
		game.morale_red,
		game.morale_black,
		game.move_actions_this_turn,
		game.card_actions_this_turn,
		game.can_end_turn()
	)

# ── 大廳 / 重啟 ───────────────────────────────────────

func _show_lobby() -> void:
	var lobby = LobbyPanelScript.new()
	add_child(lobby)
	lobby.game_start_requested.connect(_on_game_start)

func _on_game_start(deck_red_cards: Array, deck_black_cards: Array) -> void:
	game.deck_red.unlock()
	game.deck_black.unlock()
	if not game.deck_red.build_deck(deck_red_cards):
		printerr("[GameUI] Failed to build red deck")
		return
	if not game.deck_black.build_deck(deck_black_cards):
		printerr("[GameUI] Failed to build black deck")
		return
	refresh_hand()
	_update_hud()
	_refresh_once_highlights()

func restart_game() -> void:
	game.setup_standard_board()
	selected_pos = Vector2i(-1, -1)
	red_in_check = false
	black_in_check = false
	_close_once_popup()
	_clear_card_targeting()
	_update_hints()
	_rebuild_pieces()
	_update_hud()
	refresh_hand()
	_refresh_once_highlights()
	queue_redraw()
	_show_lobby()

# ── 回合切換 ──────────────────────────────────────────

func _on_end_turn_requested() -> void:
	if not game.end_turn():
		return
	selected_pos = Vector2i(-1, -1)
	_close_once_popup()
	_clear_card_targeting()
	_update_hints()
	_update_check_state()
	_update_hud()
	refresh_hand()
	_refresh_once_highlights()
	queue_redraw()

# ── 工具方法 ──────────────────────────────────────────

func _clear_card_targeting() -> void:
	targeting_card = null
	valid_card_targets.clear()
	hint_overlay.set("strategy_targets", [])
	hint_overlay.set("all_pieces_on_board", [])
	hint_overlay.is_targeting = false
	hint_overlay.set("strategy_hover_poses", [])
	hovered_pos = Vector2i(-1, -1)
	hint_overlay.queue_redraw()

func _screen_to_board(screen_pos: Vector2) -> Vector2i:
	var rel = screen_pos - BOARD_OFFSET
	var gx = roundi(rel.x / CELL_SIZE)
	var gy = roundi(rel.y / CELL_SIZE)
	return Vector2i(gx, gy)

func _board_to_screen(grid_pos: Vector2i) -> Vector2:
	return BOARD_OFFSET + Vector2(grid_pos.x * CELL_SIZE, grid_pos.y * CELL_SIZE)

func _is_valid_grid(grid: Vector2i) -> bool:
	return grid.x >= 0 and grid.x <= 8 and grid.y >= 0 and grid.y <= 9
