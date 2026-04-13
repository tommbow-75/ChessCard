class_name XiangqiGame
extends RefCounted

const MAX_ACTIONS_PER_TURN: int = 2

var board: XiangqiBoard = XiangqiBoard.new()
var current_turn: int = XiangqiPiece.Side.RED
var is_game_over: bool = false
var winner: int = -1

var sp_red: int = 0
var sp_black: int = 0
var morale_red: int = 100
var morale_black: int = 100

var pending_extra_move: bool = false
var pending_extra_move_from: Vector2i = Vector2i(-1, -1)
var pending_extra_move_forbid_capture: bool = false
var pending_extra_move_forbidden_target: int = ForbidCaptureNextMoveEffect.FORBID_ALL_TARGETS

var actions_used_this_turn: int = 0
var move_actions_this_turn: int = 0
var card_actions_this_turn: int = 0

var deck_red: DeckSystem = DeckSystem.new()
var deck_black: DeckSystem = DeckSystem.new()

const CAPTURE_SP_TABLE: Dictionary = {
	XiangqiPiece.PieceType.SOLDIER: 1,
	XiangqiPiece.PieceType.HORSE: 2,
	XiangqiPiece.PieceType.CHARIOT: 2,
	XiangqiPiece.PieceType.CANNON: 2,
	XiangqiPiece.PieceType.ELEPHANT: 1,
	XiangqiPiece.PieceType.ADVISOR: 1,
	XiangqiPiece.PieceType.GENERAL: 3,
}

const CAPTURE_MORALE_TABLE: Dictionary = {
	XiangqiPiece.PieceType.SOLDIER: 5,
	XiangqiPiece.PieceType.HORSE: 10,
	XiangqiPiece.PieceType.CHARIOT: 10,
	XiangqiPiece.PieceType.CANNON: 10,
	XiangqiPiece.PieceType.ELEPHANT: 10,
	XiangqiPiece.PieceType.ADVISOR: 10,
	XiangqiPiece.PieceType.GENERAL: 30,
}

func setup_standard_board() -> void:
	board.clear()
	current_turn = XiangqiPiece.Side.RED
	is_game_over = false
	winner = -1
	sp_red = 1
	sp_black = 0
	morale_red = 100
	morale_black = 100
	_reset_turn_state()
	deck_red = DeckSystem.new()
	deck_black = DeckSystem.new()

	board.set_piece(Vector2i(0, 0), XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.CHARIOT))
	board.set_piece(Vector2i(1, 0), XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.HORSE))
	board.set_piece(Vector2i(2, 0), XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.ELEPHANT))
	board.set_piece(Vector2i(3, 0), XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.ADVISOR))
	board.set_piece(Vector2i(4, 0), XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.GENERAL))
	board.set_piece(Vector2i(5, 0), XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.ADVISOR))
	board.set_piece(Vector2i(6, 0), XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.ELEPHANT))
	board.set_piece(Vector2i(7, 0), XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.HORSE))
	board.set_piece(Vector2i(8, 0), XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.CHARIOT))
	board.set_piece(Vector2i(1, 2), XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.CANNON))
	board.set_piece(Vector2i(7, 2), XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.CANNON))

	for i in range(5):
		board.set_piece(Vector2i(i * 2, 3), XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.SOLDIER))

	board.set_piece(Vector2i(0, 9), XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.CHARIOT))
	board.set_piece(Vector2i(1, 9), XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.HORSE))
	board.set_piece(Vector2i(2, 9), XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.ELEPHANT))
	board.set_piece(Vector2i(3, 9), XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.ADVISOR))
	board.set_piece(Vector2i(4, 9), XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.GENERAL))
	board.set_piece(Vector2i(5, 9), XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.ADVISOR))
	board.set_piece(Vector2i(6, 9), XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.ELEPHANT))
	board.set_piece(Vector2i(7, 9), XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.HORSE))
	board.set_piece(Vector2i(8, 9), XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.CHARIOT))
	board.set_piece(Vector2i(1, 7), XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.CANNON))
	board.set_piece(Vector2i(7, 7), XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.CANNON))

	for i in range(5):
		board.set_piece(Vector2i(i * 2, 6), XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.SOLDIER))

func start_turn() -> void:
	if current_turn == XiangqiPiece.Side.RED:
		sp_red += 1
	else:
		sp_black += 1

func get_remaining_actions() -> int:
	if _has_forced_follow_up_move():
		return 1
	return max(0, MAX_ACTIONS_PER_TURN - actions_used_this_turn)

func can_take_move_action() -> bool:
	if is_game_over:
		return false
	if _has_forced_follow_up_move():
		return true
	return actions_used_this_turn < MAX_ACTIONS_PER_TURN

func can_play_card_action() -> bool:
	if is_game_over:
		return false
	if _has_forced_follow_up_move():
		return false
	return actions_used_this_turn < MAX_ACTIONS_PER_TURN

func can_end_turn() -> bool:
	if is_game_over:
		return false
	if pending_extra_move:
		return false
	if pending_extra_move_from != Vector2i(-1, -1):
		return false
	if pending_extra_move_forbid_capture:
		return false
	return true

func is_pending_capture_forbidden(target_piece: XiangqiPiece) -> bool:
	if not pending_extra_move_forbid_capture or target_piece == null:
		return false
	return (
		pending_extra_move_forbidden_target == ForbidCaptureNextMoveEffect.FORBID_ALL_TARGETS
		or pending_extra_move_forbidden_target == target_piece.type
	)

func end_turn() -> bool:
	if not can_end_turn():
		return false
	current_turn = XiangqiPiece.Side.BLACK if current_turn == XiangqiPiece.Side.RED else XiangqiPiece.Side.RED
	_start_new_turn(current_turn)
	return true

func get_sp(side: int) -> int:
	return sp_red if side == XiangqiPiece.Side.RED else sp_black

func get_morale(side: int) -> int:
	return morale_red if side == XiangqiPiece.Side.RED else morale_black

func _is_basic_rule_position(pos: Vector2i, side: int) -> bool:
	if board.is_out_of_bounds(pos):
		return false
	if side == XiangqiPiece.Side.RED:
		return pos.y >= 6 and pos.y <= 9
	return pos.y >= 0 and pos.y <= 3

func summon_piece(card: SummonCardData, pos: Vector2i, side: int) -> bool:
	if not _is_basic_rule_position(pos, side):
		return false
	if board.has_piece(pos):
		return false
	if get_sp(side) < card.sp_cost:
		return false
	if side == current_turn and not can_play_card_action():
		return false

	if side == XiangqiPiece.Side.RED:
		sp_red -= card.sp_cost
	else:
		sp_black -= card.sp_cost

	var piece_type: int = _card_type_to_piece_type(card.summon_type)
	var piece := XiangqiPiece.new(side, piece_type)
	piece.special_effects = card.special_effects.duplicate()
	board.set_piece(pos, piece)

	# --- 效果觸發: SUMMON (召喚時立即觸發) ---
	var context := {"game_state": self , "side": side, "piece": piece}
	for effect in piece.special_effects:
		if effect.timing == SummonEffectTiming.Timing.SUMMON:
			effect.execute(context)

	if side == current_turn:
		_consume_card_action()

	return true

func is_in_check(defender_side: int) -> bool:
	var attacker_side = XiangqiPiece.Side.BLACK if defender_side == XiangqiPiece.Side.RED else XiangqiPiece.Side.RED
	var general_pos := Vector2i(-1, -1)

	for pos in board.pieces:
		var piece: XiangqiPiece = board.pieces[pos]
		if piece.side == defender_side and piece.type == XiangqiPiece.PieceType.GENERAL:
			general_pos = pos
			break

	if general_pos == Vector2i(-1, -1):
		return false

	for pos in board.pieces:
		var piece: XiangqiPiece = board.pieces[pos]
		if piece.side == attacker_side and XiangqiRuleVerifier.is_valid_move(board, pos, general_pos):
			return true
	return false

func _card_type_to_piece_type(card_piece_type: int) -> int:
	return card_piece_type

func move_piece(from_pos: Vector2i, to_pos: Vector2i) -> bool:
	if is_game_over:
		return false
	if not can_take_move_action():
		return false

	var locked_strategy_from := pending_extra_move_from
	var consuming_extra_move := pending_extra_move
	var piece = board.get_piece(from_pos)
	if piece == null or piece.side != current_turn:
		return false
	if piece.is_stunned:
		return false
	if locked_strategy_from != Vector2i(-1, -1) and from_pos != locked_strategy_from:
		return false
	if not XiangqiRuleVerifier.is_valid_move(board, from_pos, to_pos):
		return false

	var target: XiangqiPiece = board.get_piece(to_pos)
	var did_capture: bool = target != null and target.side != piece.side
	if did_capture and is_pending_capture_forbidden(target):
		return false

	if did_capture:
		_grant_capture_sp(target.type, current_turn)
		_deduct_capture_morale(target.type, target.side)
		_trigger_born_capture_effects(piece)

	board.remove_piece(from_pos)
	board.set_piece(to_pos, piece)

	if did_capture:
		_trigger_and_consume_once_effects(piece)

	_consume_move_action()

	if locked_strategy_from != Vector2i(-1, -1):
		pending_extra_move_from = Vector2i(-1, -1)
		pending_extra_move_forbid_capture = false
		pending_extra_move_forbidden_target = ForbidCaptureNextMoveEffect.FORBID_ALL_TARGETS
	if consuming_extra_move:
		pending_extra_move = false

	return true

func _start_new_turn(side: int) -> void:
	_reset_turn_state()

	if side == XiangqiPiece.Side.RED:
		sp_red += 1
	else:
		sp_black += 1

	var deck = deck_red if side == XiangqiPiece.Side.RED else deck_black
	deck.draw_card()

	for y in range(10):
		for x in range(9):
			var piece = board.get_piece(Vector2i(x, y))
			if piece != null and piece.side == side and piece.is_stunned:
				piece.stun_duration -= 1
				if piece.stun_duration <= 0:
					piece.is_stunned = false

func play_strategy_card(card: StrategyCardData, target_pos: Vector2i = Vector2i(-1, -1)) -> bool:
	if is_game_over:
		return false
	if not can_play_card_action():
		return false

	var side = current_turn
	var current_sp = sp_red if side == XiangqiPiece.Side.RED else sp_black
	if current_sp < card.sp_cost:
		return false

	# 檢查是否需要瞄準
	var needs_targeting := false
	for eff in card.special_effects:
		if eff is StrategyEffectTiming and eff.target_type != null and eff.target_type.type != TargetType.Type.PLAYER:
			needs_targeting = true
			break
	
	if needs_targeting and target_pos == Vector2i(-1, -1):
		return false

	for eff in card.special_effects:
		if not (eff is StrategyEffectTiming):
			continue
		
		var context := {"game": self , "caster_side": side, "target_pos": target_pos}
		var affected = eff.get_affected_cells(target_pos, context)
		
		# 這裡不檢查 affected 是否為空，因為 PLAYER 類型的效果 affected 為空是正常的
		# 實際上 is_valid_target 已經在 UI 端做過初步驗證了
		context["affected_positions"] = affected
		eff.execute(context)

	if side == XiangqiPiece.Side.RED:
		sp_red -= card.sp_cost
	else:
		sp_black -= card.sp_cost

	var deck = deck_red if side == XiangqiPiece.Side.RED else deck_black
	deck.play_card(card)
	_consume_card_action()

	return true

func get_valid_strategy_targets(card: StrategyCardData) -> Array[Vector2i]:
	var valid_poses: Array[Vector2i] = []
	if card.special_effects.size() == 0:
		return valid_poses

	# 這裡我們只取第一個效果來判斷瞄準（大部分謀略卡只有一個主效果）
	var eff = card.special_effects[0] as StrategyEffectTiming
	if eff == null:
		return valid_poses
	
	# 如果是針對玩家，不需要瞄準棋盤格
	if eff.target_type != null and eff.target_type.type == TargetType.Type.PLAYER:
		return valid_poses

	if eff.target_mode != null and eff.target_mode.mode == TargetMode.Mode.AREA_3X3:
		for y in range(10):
			for x in range(9):
				valid_poses.append(Vector2i(x, y))
		return valid_poses

	for y in range(10):
		for x in range(9):
			var pos := Vector2i(x, y)
			var context := {"game": self , "caster_side": current_turn, "target_pos": pos}
			if eff.is_valid_target(pos, context):
				valid_poses.append(pos)
	return valid_poses

func get_valid_summon_positions(_card: SummonCardData) -> Array[Vector2i]:
	var valid_poses: Array[Vector2i] = []
	var side = current_turn
	for y in range(10):
		for x in range(9):
			var pos := Vector2i(x, y)
			if _is_basic_rule_position(pos, side) and not board.has_piece(pos):
				valid_poses.append(pos)
	return valid_poses

func _grant_capture_sp(piece_type: int, attacker_side: int) -> void:
	var amount: int = CAPTURE_SP_TABLE.get(piece_type, 0)
	if attacker_side == XiangqiPiece.Side.RED:
		sp_red += amount
	else:
		sp_black += amount

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

# --- 效果觸發: BORN (天生技能/吃子時持續生效) ---
func _trigger_born_capture_effects(piece: XiangqiPiece) -> void:
	var context := {"game_state": self , "side": piece.side, "piece": piece}
	for effect in piece.special_effects:
		if effect.timing == SummonEffectTiming.Timing.BORN and effect is RestoreOnCaptureEffect:
			effect.execute(context)

# --- 效果觸發: ONCE (限發動一次，發動完移除效果) ---
func _trigger_and_consume_once_effects(piece: XiangqiPiece) -> void:
	var context := {"game_state": self , "side": piece.side, "piece": piece}
	var to_remove: Array = []
	for effect in piece.special_effects:
		if effect.timing == SummonEffectTiming.Timing.ONCE:
			effect.execute(context)
			to_remove.append(effect)
	for effect in to_remove:
		piece.special_effects.erase(effect)

func _has_forced_follow_up_move() -> bool:
	return pending_extra_move or pending_extra_move_from != Vector2i(-1, -1)

func _consume_move_action() -> void:
	actions_used_this_turn += 1
	move_actions_this_turn += 1

func _consume_card_action() -> void:
	actions_used_this_turn += 1
	card_actions_this_turn += 1

func _reset_turn_state() -> void:
	actions_used_this_turn = 0
	move_actions_this_turn = 0
	card_actions_this_turn = 0
	pending_extra_move = false
	pending_extra_move_from = Vector2i(-1, -1)
	pending_extra_move_forbid_capture = false
	pending_extra_move_forbidden_target = ForbidCaptureNextMoveEffect.FORBID_ALL_TARGETS
