class_name GridSystem
extends Node

## Godot 中國象棋網格座標轉換系統與碰撞/邊界檢測基礎
## 棋盤座標系統： x 軸為橫向 (0~8)，y 軸為直向 (0~9)

const COLS = 9
const ROWS = 10

# 將在畫面中顯示的一個格子大小像素數 (供示範與擴充使用)
const CELL_SIZE = Vector2(80, 80)
# 起始偏移量
const MARGIN = Vector2(40, 40)

# 使用 Dictionary 來儲存座標狀態 (Vector2: piece)
var _grid: Dictionary = {}

func _ready() -> void:
	clear_grid()

## 清空網格內容
func clear_grid() -> void:
	_grid.clear()
	for x in range(COLS):
		for y in range(ROWS):
			_grid[Vector2(x, y)] = null

## 檢驗座標是否合法 (9x10 範圍內)
func is_valid_pos(pos: Vector2) -> bool:
	return pos.x >= 0 and pos.x < COLS and pos.y >= 0 and pos.y < ROWS

## 將網格座標轉換為畫面像素座標 (供畫面渲染使用)
func grid_to_pixel(grid_pos: Vector2) -> Vector2:
	return grid_pos * CELL_SIZE + MARGIN

## 將畫面像素座標轉換為最近的網格座標 (供鼠標點擊使用)
func pixel_to_grid(pixel_pos: Vector2) -> Vector2:
	var raw = (pixel_pos - MARGIN) / CELL_SIZE
	var grid_pos = Vector2(round(raw.x), round(raw.y))
	return grid_pos

## 獲取特定座標上的棋子或空狀態
func get_piece_at(pos: Vector2):
	if not is_valid_pos(pos):
		return null
	return _grid.get(pos, null)

## 設定特定座標上的棋子
func set_piece_at(pos: Vector2, piece) -> bool:
	if not is_valid_pos(pos):
		return false
	_grid[pos] = piece
	return true

## 移除特定座標上的棋子並回傳該棋子
func remove_piece_at(pos: Vector2):
	if not is_valid_pos(pos):
		return null
	var piece = _grid.get(pos, null)
	_grid[pos] = null
	return piece

## 移動棋子 (單純的資料轉移不包含規則驗證)
func move_piece(from_pos: Vector2, to_pos: Vector2) -> bool:
	if not is_valid_pos(from_pos) or not is_valid_pos(to_pos):
		return false
	
	var piece = get_piece_at(from_pos)
	if piece == null:
		return false
		
	set_piece_at(to_pos, piece)
	remove_piece_at(from_pos)
	return true
