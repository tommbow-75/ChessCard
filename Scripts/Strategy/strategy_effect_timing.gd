class_name StrategyEffectTiming
extends Resource

## 目標選取 - Level 3：陣營
## 規格：僅 SELF / ENEMY / ANY，不提供 NONE
enum TargetFaction {
	SELF,   # 選自方格子
	ENEMY,  # 選敵方格子
	ANY,    # 任何格子（不分陣營）
}

## 目標選取 - Level 5：選擇模式
enum TargetMode {
	NONE,       # 不需要選格，直接發動（BORN 型效果使用）
	SINGLE,     # 點選單一格
	AREA_3X3,   # 點選中心格，影響周圍 3×3 所有格
}

## ── Level 4 Piece bitmask 常數 ──────────────────────────────────────
const PIECE_GENERAL  := 1    # bit 0
const PIECE_ADVISOR  := 2    # bit 1
const PIECE_ELEPHANT := 4    # bit 2
const PIECE_HORSE    := 8    # bit 3
const PIECE_CHARIOT  := 16   # bit 4
const PIECE_CANNON   := 32   # bit 5
const PIECE_SOLDIER  := 64   # bit 6

## ── Export 欄位 ─────────────────────────────────────────────────────
## L3：陣營
@export var target_faction: TargetFaction = TargetFaction.SELF

## L4：可選棋子種類（bitmask，可複選；不使用 piece_all，預設全選）
@export_flags("General", "Advisor", "Elephant", "Horse", "Chariot", "Cannon", "Soldier")
var target_piece_mask: int = 127

## L5：選擇模式
@export var target_mode: TargetMode = TargetMode.SINGLE

## ── 統一目標驗證（子類不須 override）───────────────────────────────
## 判斷「center_pos 是否可被點選作為目標」
## AREA_3X3 模式下 center 本身不做限制（任意格皆可選，範圍內格子才過濾）
func is_valid_target(board_pos: Vector2i, context: Dictionary) -> bool:
	if target_mode == TargetMode.NONE:
		return false  # 不需要選格，此函式不應被呼叫
	var game = context.get("game")
	if game == null:
		return false

	if target_mode == TargetMode.AREA_3X3:
		# 選擇模式為 3x3 時，中心點本身不限制（任何格都可當中心）
		return true

	# SINGLE 模式：嚴格驗證 board_pos
	return _cell_matches(board_pos, game, context.get("caster_side"))

## ── 取得效果作用的實際格子列表 ──────────────────────────────────────
## 由 play_strategy_card 在 execute() 前呼叫，結果注入 context["affected_positions"]
func get_affected_cells(center: Vector2i, context: Dictionary) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	if target_mode == TargetMode.NONE:
		return result  # 不需要格子（player 型效果）
	var game = context.get("game")
	if game == null:
		return result
	var side = context.get("caster_side")

	if target_mode == TargetMode.SINGLE:
		if _cell_matches(center, game, side):
			result.append(center)
	elif target_mode == TargetMode.AREA_3X3:
		for dx in range(-1, 2):
			for dy in range(-1, 2):
				var p = Vector2i(center.x + dx, center.y + dy)
				if not game.board.is_out_of_bounds(p):
					if _cell_matches(p, game, side):
						result.append(p)
	return result

## ── 實際執行效果（子類 override）───────────────────────────────────
## context 包含：
##   "game": XiangqiGame
##   "caster_side": int（Side）
##   "target_pos": Vector2i（中心格、或 NONE 時為 Vector2i(-1,-1)）
##   "affected_positions": Array[Vector2i]（實際作用格列表）
func execute(_context: Dictionary) -> void:
	pass

## ── 私有：判斷單格是否符合 L3+L4 條件 ──────────────────────────────
func _cell_matches(pos: Vector2i, game, caster_side: int) -> bool:
	var piece = game.board.get_piece(pos)
	if piece == null:
		return false  # 空格不屬於任何陣營，不匹配
	var enemy_side = XiangqiPiece.Side.BLACK if caster_side == XiangqiPiece.Side.RED else XiangqiPiece.Side.RED

	# 驗 L3 陣營
	match target_faction:
		TargetFaction.SELF:
			if piece.side != caster_side:
				return false
		TargetFaction.ENEMY:
			if piece.side != enemy_side:
				return false
		TargetFaction.ANY:
			pass  # 不限

	# 驗 L4 棋子種類
	return _piece_type_matches(piece.type)

func _piece_type_matches(piece_type: int) -> bool:
	var bit := 0
	match piece_type:
		XiangqiPiece.PieceType.GENERAL:   bit = PIECE_GENERAL
		XiangqiPiece.PieceType.ADVISOR:   bit = PIECE_ADVISOR
		XiangqiPiece.PieceType.ELEPHANT:  bit = PIECE_ELEPHANT
		XiangqiPiece.PieceType.HORSE:     bit = PIECE_HORSE
		XiangqiPiece.PieceType.CHARIOT:   bit = PIECE_CHARIOT
		XiangqiPiece.PieceType.CANNON:    bit = PIECE_CANNON
		XiangqiPiece.PieceType.SOLDIER:   bit = PIECE_SOLDIER
		_: return false
	return (target_piece_mask & bit) != 0
