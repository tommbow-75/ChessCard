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

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_pos = get_local_mouse_position()
		var grid = _screen_to_board(local_pos)
		if _is_valid_grid(grid):
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
			elif targeting_card is SummonCardData:
				if game.summon_piece(targeting_card, grid, game.current_turn):
					_clear_card_targeting()
					_rebuild_pieces()
					_update_check_state()
					_update_hud()
					refresh_hand()
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
		# 這裡可以加入提示：目前無法執行卡牌行動
		return

	if card is StrategyCardData:
		var targets = game.get_valid_strategy_targets(card)
		if targets.is_empty():
			# 如果沒有合法目標（通常代表是針對玩家的效果），則立刻發動
			if game.play_strategy_card(card):
				_rebuild_pieces()
				_update_check_state()
				_update_hud()
				refresh_hand()
		else:
			# 進入策略卡瞄準模式
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
			hint_overlay.set("strategy_targets", valid_card_targets) # 沿用 strategy_targets 的視覺效果
			hint_overlay.set("all_pieces_on_board", game.board.pieces.keys())
			hint_overlay.is_targeting = true
			hint_overlay.queue_redraw()

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
		game.actions_used_this_turn,
		game.move_actions_this_turn,
		game.card_actions_this_turn,
		game.can_end_turn()
	)

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

func _screen_to_board(screen_pos: Vector2) -> Vector2i:
	var rel = screen_pos - BOARD_OFFSET
	var gx = roundi(rel.x / CELL_SIZE)
	var gy = roundi(rel.y / CELL_SIZE)
	return Vector2i(gx, gy)

func _is_valid_grid(grid: Vector2i) -> bool:
	return grid.x >= 0 and grid.x <= 8 and grid.y >= 0 and grid.y <= 9

func restart_game() -> void:
	game.setup_standard_board()
	selected_pos = Vector2i(-1, -1)
	red_in_check = false
	black_in_check = false
	_clear_card_targeting()
	_update_hints()
	_rebuild_pieces()
	_update_hud()
	refresh_hand()
	queue_redraw()
	_show_lobby()

func _on_end_turn_requested() -> void:
	if not game.end_turn():
		return
	selected_pos = Vector2i(-1, -1)
	_clear_card_targeting()
	_update_hints()
	_update_check_state()
	_update_hud()
	refresh_hand()
	queue_redraw()

func _clear_card_targeting() -> void:
	targeting_card = null
	valid_card_targets.clear()
	hint_overlay.set("strategy_targets", [])
	hint_overlay.set("all_pieces_on_board", [])
	hint_overlay.is_targeting = false
	hint_overlay.set("strategy_hover_poses", [])
	hovered_pos = Vector2i(-1, -1)
	hint_overlay.queue_redraw()
