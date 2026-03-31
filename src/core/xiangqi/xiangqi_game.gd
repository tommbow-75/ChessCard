class_name XiangqiGame
extends RefCounted

var board: XiangqiBoard = XiangqiBoard.new()
var current_turn: int = XiangqiPiece.Side.RED
var is_game_over: bool = false
var winner: int = -1

## ── 進階規則：SP & 士氣 ──────────────────────────────────────────
var sp_red: int = 0
var sp_black: int = 0
var morale_red: int = 100
var morale_black: int = 100

## 火焰車效果：若為 true，本次移動後不換邊，允許再走一次
var pending_extra_move: bool = false

## ── 牌庫系統 ──────────────────────────────────────────────────────
## 每個玩家各自擁有一個牌庫；預設為空，遊戲開始前需透過 build_deck() 建立
var deck_red: DeckSystem = DeckSystem.new()
var deck_black: DeckSystem = DeckSystem.new()

## 吃子 SP 獎勵表（依 AdvancedRule.md §1-1）
const CAPTURE_SP_TABLE: Dictionary = {
	XiangqiPiece.PieceType.SOLDIER:  1,
	XiangqiPiece.PieceType.HORSE:    2,
	XiangqiPiece.PieceType.CHARIOT:  2,
	XiangqiPiece.PieceType.CANNON:   2,
	XiangqiPiece.PieceType.ELEPHANT: 1,
	XiangqiPiece.PieceType.ADVISOR:  1,
	XiangqiPiece.PieceType.GENERAL:  3,
}

## 被吃子士氣扣除表（依 README.md Morale Values）
const CAPTURE_MORALE_TABLE: Dictionary = {
	XiangqiPiece.PieceType.SOLDIER:  5,
	XiangqiPiece.PieceType.HORSE:    10,
	XiangqiPiece.PieceType.CHARIOT:  10,
	XiangqiPiece.PieceType.CANNON:   10,
	XiangqiPiece.PieceType.ELEPHANT: 10,
	XiangqiPiece.PieceType.ADVISOR:  10,
	XiangqiPiece.PieceType.GENERAL:  30,
}

# ─────────────────────────────────────────────────────────────────

func setup_standard_board():
	board.clear()
	current_turn = XiangqiPiece.Side.RED
	is_game_over = false
	sp_red = 1
	sp_black = 0
	winner = -1
	morale_red = 100
	morale_black = 100
	pending_extra_move = false
	# 重置牌庫（保留原有牌組，若已透過 build_deck 建立則重新洗牌）
	deck_red = DeckSystem.new()
	deck_black = DeckSystem.new()
	
	# Setting up BLACK
	board.set_piece(Vector2i(0,0), XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.CHARIOT))
	board.set_piece(Vector2i(1,0), XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.HORSE))
	board.set_piece(Vector2i(2,0), XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.ELEPHANT))
	board.set_piece(Vector2i(3,0), XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.ADVISOR))
	board.set_piece(Vector2i(4,0), XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.GENERAL))
	board.set_piece(Vector2i(5,0), XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.ADVISOR))
	board.set_piece(Vector2i(6,0), XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.ELEPHANT))
	board.set_piece(Vector2i(7,0), XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.HORSE))
	board.set_piece(Vector2i(8,0), XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.CHARIOT))
	
	board.set_piece(Vector2i(1,2), XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.CANNON))
	board.set_piece(Vector2i(7,2), XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.CANNON))
	
	for i in range(5):
		board.set_piece(Vector2i(i*2, 3), XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.SOLDIER))
		
	# Setting up RED
	board.set_piece(Vector2i(0,9), XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.CHARIOT))
	board.set_piece(Vector2i(1,9), XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.HORSE))
	board.set_piece(Vector2i(2,9), XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.ELEPHANT))
	board.set_piece(Vector2i(3,9), XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.ADVISOR))
	board.set_piece(Vector2i(4,9), XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.GENERAL))
	board.set_piece(Vector2i(5,9), XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.ADVISOR))
	board.set_piece(Vector2i(6,9), XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.ELEPHANT))
	board.set_piece(Vector2i(7,9), XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.HORSE))
	board.set_piece(Vector2i(8,9), XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.CHARIOT))
	
	board.set_piece(Vector2i(1,7), XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.CANNON))
	board.set_piece(Vector2i(7,7), XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.CANNON))
	
	for i in range(5):
		board.set_piece(Vector2i(i*2, 6), XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.SOLDIER))

## ── SP 系統 ──────────────────────────────────────────────────────

## 回合開始：呼叫此函式讓當前玩家獲得 1 SP（AdvancedRule §1-1.1）
func start_turn() -> void:
	if current_turn == XiangqiPiece.Side.RED:
		sp_red += 1
	else:
		sp_black += 1

## 取得指定陣營的當前 SP
func get_sp(side: int) -> int:
	return sp_red if side == XiangqiPiece.Side.RED else sp_black

## 取得指定陣營的當前士氣
func get_morale(side: int) -> int:
	return morale_red if side == XiangqiPiece.Side.RED else morale_black

## ── 召喚邏輯 ─────────────────────────────────────────────────────

## 判斷目標格是否在指定陣營的基礎規則點（入場區）
## 紅方：y = 6~9，黑方：y = 0~3
func _is_basic_rule_position(pos: Vector2i, side: int) -> bool:
	if board.is_out_of_bounds(pos):
		return false
	if side == XiangqiPiece.Side.RED:
		return pos.y >= 6 and pos.y <= 9
	else:
		return pos.y >= 0 and pos.y <= 3

## 召喚一張召喚卡到棋盤上
## 回傳 true 代表成功，false 代表失敗（SP 不足、格子被佔 或 位置不合法）
func summon_piece(card: SummonCardData, pos: Vector2i, side: int) -> bool:
	# 1. 位置必須在本方入場區
	if not _is_basic_rule_position(pos, side):
		return false
	
	# 2. 目標格不可有任何棋子
	if board.has_piece(pos):
		return false
	
	# 3. SP 必須足夠
	if get_sp(side) < card.sp_cost:
		return false
	
	# 4. 扣除 SP
	if side == XiangqiPiece.Side.RED:
		sp_red -= card.sp_cost
	else:
		sp_black -= card.sp_cost
	
	# 5. 建立棋子並複製效果積木
	var piece_type: int = _card_type_to_piece_type(card.summon_type)
	var piece = XiangqiPiece.new(side, piece_type)
	piece.special_effects = card.special_effects.duplicate()
	board.set_piece(pos, piece)
	
	# 6. 觸發所有 SUMMON 類效果
	var context = {"game_state": self, "side": side, "piece": piece}
	for effect in piece.special_effects:
		if effect.timing == SummonEffectTiming.Timing.SUMMON:
			effect.execute(context)
	
	return true

## 判斷 defender_side 的將是否正被威脅（將軍）
## 遍歷攻方所有棋子，若任一走步可到達對方 General 位置 → 返回 true
func is_in_check(defender_side: int) -> bool:
	var attacker_side = XiangqiPiece.Side.BLACK if defender_side == XiangqiPiece.Side.RED else XiangqiPiece.Side.RED
	
	# 找到防守方 General 的位置
	var general_pos = Vector2i(-1, -1)
	for pos in board.pieces:
		var p = board.pieces[pos]
		if p.side == defender_side and p.type == XiangqiPiece.PieceType.GENERAL:
			general_pos = pos
			break
	
	if general_pos == Vector2i(-1, -1):
		return false # 找不到 General（已被吃掉）
	
	# 遍歷攻方所有棋子，看是否有棋子能走到 general_pos
	for pos in board.pieces:
		var p = board.pieces[pos]
		if p.side == attacker_side:
			if XiangqiRuleVerifier.is_valid_move(board, pos, general_pos):
				return true
	return false

## 將 ChessPieceData.PieceType 轉換為 XiangqiPiece.PieceType（兩者 Enum 順序相同）
func _card_type_to_piece_type(card_piece_type: int) -> int:
	return card_piece_type

## ── 移動邏輯 ─────────────────────────────────────────────────────

func move_piece(from_pos: Vector2i, to_pos: Vector2i) -> bool:
	if is_game_over:
		return false
		
	var piece = board.get_piece(from_pos)
	if piece == null or piece.side != current_turn:
		return false
		
	if piece.is_stunned:
		return false
		
	if not XiangqiRuleVerifier.is_valid_move(board, from_pos, to_pos):
		return false
		
	var target = board.get_piece(to_pos)
	var did_capture = (target != null)
	
	if did_capture:
		# 攻方獲得 SP
		_grant_capture_sp(target.type, current_turn)
		
		# 扣除被吃方士氣
		_deduct_capture_morale(target.type, target.side)
		
		# 觸發攻方棋子天生效果（如猛將吃子回血）
		_trigger_born_capture_effects(piece)
	
	board.remove_piece(from_pos)
	board.set_piece(to_pos, piece)
	
	# 觸發一次性效果（吃子後才有意義，但部分效果也可在普通移動觸發）
	if did_capture:
		_trigger_and_consume_once_effects(piece)
	
	# 判斷是否有「再移動一次」的 pending 狀態
	if not is_game_over:
		if pending_extra_move:
			pending_extra_move = false
			# 不換邊，讓同一玩家再走一次
		else:
			current_turn = XiangqiPiece.Side.BLACK if current_turn == XiangqiPiece.Side.RED else XiangqiPiece.Side.RED
			_start_new_turn(current_turn)

	return true

func _start_new_turn(side: int) -> void:
	if side == XiangqiPiece.Side.RED:
		sp_red += 1
	else:
		sp_black += 1

	# 回合開始：該陣營抽一張謀略卡
	var deck = deck_red if side == XiangqiPiece.Side.RED else deck_black
	deck.draw_card()

	# 解除該陣營棋子的暈眩
	for y in range(10):
		for x in range(9):
			var p = board.get_piece(Vector2i(x, y))
			if p != null and p.side == side and p.is_stunned:
				p.stun_duration -= 1
				if p.stun_duration <= 0:
					p.is_stunned = false

## ── 謀略卡系統 ──────────────────────────────────────────────────

func play_strategy_card(card: StrategyCardData, target_pos: Vector2i = Vector2i(-1, -1)) -> bool:
	if is_game_over: return false

	# 檢查 SP
	var current_sp = sp_red if current_turn == XiangqiPiece.Side.RED else sp_black
	if current_sp < card.sp_cost:
		return false

	# 執行所有 effects
	for eff in card.special_effects:
		if not (eff is StrategyEffectTiming):
			continue
		var context = {"game": self, "caster_side": current_turn, "target_pos": target_pos}
		if eff.target_mode == StrategyEffectTiming.TargetMode.NONE:
			# 不需要目標，直接發動
			context["affected_positions"] = []
			eff.execute(context)
		else:
			# 計算实際作用的格子列表
			var affected = eff.get_affected_cells(target_pos, context)
			if affected.is_empty():
				return false  # 目標不合法
			context["affected_positions"] = affected
			eff.execute(context)

	# 扣除 SP
	if current_turn == XiangqiPiece.Side.RED:
		sp_red -= card.sp_cost
	else:
		sp_black -= card.sp_cost

	# 使用後：將卡牌移入棄牌區
	var deck = deck_red if current_turn == XiangqiPiece.Side.RED else deck_black
	deck.play_card(card)

	return true

func get_valid_strategy_targets(card: StrategyCardData) -> Array[Vector2i]:
	var valid_poses: Array[Vector2i] = []
	if card.special_effects.size() == 0:
		return valid_poses
	var eff = card.special_effects[0] as StrategyEffectTiming
	if eff == null or eff.target_mode == StrategyEffectTiming.TargetMode.NONE:
		return valid_poses

	# AREA_3X3: 中心點不限，任何格都可選
	if eff.target_mode == StrategyEffectTiming.TargetMode.AREA_3X3:
		for y in range(10):
			for x in range(9):
				valid_poses.append(Vector2i(x, y))
		return valid_poses

	# SINGLE: 嚴格驗證每格
	for y in range(10):
		for x in range(9):
			var pos = Vector2i(x, y)
			var context = {"game": self, "caster_side": current_turn, "target_pos": pos}
			if eff.is_valid_target(pos, context):
				valid_poses.append(pos)
	return valid_poses

## ── 私有輔助函式 ──────────────────────────────────────────────────

## 依照吃子種類給攻方 SP
func _grant_capture_sp(piece_type: int, attacker_side: int) -> void:
	var amount: int = CAPTURE_SP_TABLE.get(piece_type, 0)
	if attacker_side == XiangqiPiece.Side.RED:
		sp_red += amount
	else:
		sp_black += amount

## 依照被吃子種類扣除擁有方士氣
func _deduct_capture_morale(piece_type: int, victim_side: int) -> void:
	var amount: int = CAPTURE_MORALE_TABLE.get(piece_type, 0)
	if victim_side == XiangqiPiece.Side.RED:
		morale_red = max(0, morale_red - amount)
		if morale_red == 0 and not is_game_over:
			is_game_over = true
			winner = XiangqiPiece.Side.BLACK
	else:
		morale_black = max(0, morale_black - amount)
		if morale_black == 0 and not is_game_over:
			is_game_over = true
			winner = XiangqiPiece.Side.RED

## 吃子後觸發棋子上所有 BORN 的吃子類效果（如猛將回血）
func _trigger_born_capture_effects(piece: XiangqiPiece) -> void:
	var context = {"game_state": self, "side": piece.side, "piece": piece}
	for effect in piece.special_effects:
		if effect.timing == SummonEffectTiming.Timing.BORN:
			if effect is RestoreOnCaptureEffect:
				effect.execute(context)

## 吃子後觸發棋子上所有 ONCE 的效果，執行後從列表移除
func _trigger_and_consume_once_effects(piece: XiangqiPiece) -> void:
	var context = {"game_state": self, "side": piece.side, "piece": piece}
	var to_remove: Array = []
	for effect in piece.special_effects:
		if effect.timing == SummonEffectTiming.Timing.ONCE:
			effect.execute(context)
			to_remove.append(effect)
	for e in to_remove:
		piece.special_effects.erase(e)
