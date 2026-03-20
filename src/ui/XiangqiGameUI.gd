extends Node2D

## 象棋主控制器
## 整合 XiangqiGame 核心邏輯，處理滑鼠點選、棋子選取、走子、回合切換

const BOARD_OFFSET := Vector2(50, 50)
const CELL_SIZE    := 70

@onready var board_renderer: Node2D = $BoardRenderer
@onready var pieces_layer:   Node2D = $PiecesLayer
@onready var hint_overlay:   Node2D = $HintOverlay
@onready var hud: Node         = $HUD

var game: XiangqiGame
var selected_pos := Vector2i(-1, -1)
var piece_views: Dictionary = {} # Vector2i -> PieceView Node2D

const PieceViewScript = preload("res://src/ui/PieceView.gd")

func _ready():
	game = XiangqiGame.new()
	game.setup_standard_board()
	_rebuild_pieces()
	_update_hud()
	# 連接重新開始信號
	if hud and hud.has_signal("restart_requested"):
		hud.restart_requested.connect(restart_game)

func _input(event: InputEvent):
	if game.is_game_over:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var local_pos = get_local_mouse_position()
		var grid = _screen_to_board(local_pos)
		if _is_valid_grid(grid):
			_handle_click(grid)

# ──────────────────────────────────────────────
# 點擊邏輯
# ──────────────────────────────────────────────
func _handle_click(grid: Vector2i):
	var piece = game.board.get_piece(grid)

	# 點自己的棋子 → 選取
	if piece != null and piece.side == game.current_turn:
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
			_update_hud()
			return

	# 點空格或點到敵方但沒選子 → 取消選取
	selected_pos = Vector2i(-1, -1)
	_update_hints()

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
						hint_overlay.capture_positions.append(to)  # 敵方棋子→紅點（疊在棋子上）
					else:
						board_renderer.hint_positions.append(to)   # 空格→藍點

	board_renderer.queue_redraw()
	hint_overlay.queue_redraw()

# ──────────────────────────────────────────────
# 重建棋子視覺
# ──────────────────────────────────────────────
func _rebuild_pieces():
	# 移除舊的
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
# HUD 更新
# ──────────────────────────────────────────────
func _update_hud():
	if hud == null:
		return
	hud.update_state(game.current_turn, game.is_game_over, game.winner)

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
	_update_hints()
	_rebuild_pieces()
	_update_hud()
