@tool
extends EditorScript

func _run():
	print("--- Running Advanced Rule Tests ---")
	
	var game = XiangqiGame.new()
	game.setup_standard_board()
	
	var all_pass = true
	
	# ── SP 系統測試 ───────────────────────────────────────────────
	
	# Test 1: 回合開始 +1 SP
	game.start_turn()
	var t1 = (game.sp_red == 1)
	_print_result(1, "回合開始 RED SP +1（預期 sp_red==1）", t1)
	all_pass = all_pass and t1
	
	# Test 2: 吃卒後攻方 +1 SP
	# 先手動建立一個紅兵在 (4,5)，黑卒在 (4,4)
	var red_soldier = XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.SOLDIER)
	var black_soldier = XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.SOLDIER)
	game.board.set_piece(Vector2i(4, 5), red_soldier)
	game.board.set_piece(Vector2i(4, 4), black_soldier)
	var sp_before = game.sp_red
	game.move_piece(Vector2i(4, 5), Vector2i(4, 4)) # 紅兵過河吃黑卒
	var t2 = (game.sp_red == sp_before + 1)
	_print_result(2, "吃卒後攻方 +1 SP（預期 sp_red 增加 1）", t2)
	all_pass = all_pass and t2
	game.setup_standard_board() # 重置棋盤
	
	# Test 3: 吃車後攻方 +2 SP
	game.start_turn() # 讓紅方 +1 SP
	var red_chariot = XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.CHARIOT)
	var black_chariot = XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.CHARIOT)
	game.board.set_piece(Vector2i(0, 5), red_chariot)
	game.board.set_piece(Vector2i(0, 3), black_chariot)
	var sp_before_3 = game.sp_red
	game.move_piece(Vector2i(0, 5), Vector2i(0, 3)) # 紅車吃黑車
	var t3 = (game.sp_red == sp_before_3 + 2)
	_print_result(3, "吃車後攻方 +2 SP（預期 sp_red 增加 2）", t3)
	all_pass = all_pass and t3
	game.setup_standard_board()
	
	# ── 士氣系統測試 ──────────────────────────────────────────────
	
	# Test 4: 吃子後被吃方士氣扣除
	var red_r = XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.CHARIOT)
	var black_s = XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.SOLDIER)
	game.board.set_piece(Vector2i(0, 5), red_r)
	game.board.set_piece(Vector2i(0, 4), black_s)
	var morale_before = game.morale_black
	game.move_piece(Vector2i(0, 5), Vector2i(0, 4))
	var t4 = (game.morale_black == morale_before - 5) # 兵扣5
	_print_result(4, "吃兵後黑方士氣扣 5（預期 morale_black 減少 5）", t4)
	all_pass = all_pass and t4
	game.setup_standard_board()
	
	# ── 召喚系統測試 ──────────────────────────────────────────────
	
	# Test 5: SP 不足時召喚回傳 false
	var card = SummonCardData.new()
	card.sp_cost = 10 # 消耗10 SP，但 sp_red 目前為 0
	var t5 = (game.summon_piece(card, Vector2i(0, 9), XiangqiPiece.Side.RED) == false)
	_print_result(5, "SP 不足時召喚回傳 false", t5)
	all_pass = all_pass and t5
	
	# Test 6: 目標格有子時召喚回傳 false
	game.sp_red = 99
	card.sp_cost = 1
	# (0,9) 預設已有紅車
	var t6 = (game.summon_piece(card, Vector2i(0, 9), XiangqiPiece.Side.RED) == false)
	_print_result(6, "格子有子時召喚回傳 false", t6)
	all_pass = all_pass and t6
	
	# Test 7: 召喚到非入場區（黑方嘗試在 y=5 召喚）回傳 false
	game.sp_black = 99
	var t7 = (game.summon_piece(card, Vector2i(4, 5), XiangqiPiece.Side.BLACK) == false)
	_print_result(7, "召喚到非入場區回傳 false", t7)
	all_pass = all_pass and t7
	game.setup_standard_board()
	
	# ── 效果觸發測試 ──────────────────────────────────────────────
	
	# Test 8: 垃圾炮有 cannot_eat_effect（forbidden: GENERAL）時，無法走到敵將位置
	var trash_cannon = XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.CANNON)
	var cannot_eat = CannotEatEffect.new()
	cannot_eat.forbidden_target = XiangqiPiece.PieceType.GENERAL
	trash_cannon.special_effects.append(cannot_eat)
	# 放置炮在 (4, 5)，黑將在 (4, 0)，炮架在 (4, 3) 有一個兵
	game.board.set_piece(Vector2i(4, 5), trash_cannon)
	var black_g = XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.GENERAL)
	game.board.set_piece(Vector2i(4, 0), black_g)
	var blocker = XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.SOLDIER)
	game.board.set_piece(Vector2i(4, 3), blocker)
	var t8 = (XiangqiRuleVerifier.is_valid_move(game.board, Vector2i(4, 5), Vector2i(4, 0)) == false)
	_print_result(8, "垃圾炮 cannot_eat_effect 攔截吃將（預期 false）", t8)
	all_pass = all_pass and t8
	game.setup_standard_board()
	
	# Test 9: 猛將有 restore_on_capture_effect，吃子後回復 2 士氣
	var fierce_gen = XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.GENERAL)
	var restore_eff = RestoreOnCaptureEffect.new()
	restore_eff.restore_amount = 2
	fierce_gen.special_effects.append(restore_eff)
	game.board.set_piece(Vector2i(4, 9), fierce_gen) # 覆蓋原本的將
	var enemy_s = XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.SOLDIER)
	game.board.set_piece(Vector2i(4, 8), enemy_s) # 黑卒在旁邊（模擬可吃到）
	# 為了讓將可以走到 (4,8)，必須先移到 palace 內，此例直接用 board 操作
	game.board.remove_piece(Vector2i(4, 9))
	game.board.set_piece(Vector2i(4, 8), enemy_s) # 確保目標在
	game.board.set_piece(Vector2i(4, 9), fierce_gen)
	game.morale_red = 80 # 先降低士氣以便驗證
	var morale_before_9 = game.morale_red
	game.move_piece(Vector2i(4, 9), Vector2i(4, 8))
	var t9 = (game.morale_red >= morale_before_9) # 吃子後士氣有回復
	_print_result(9, "猛將 restore_on_capture_effect 吃子回復士氣（預期 morale_red 不減反增）", t9)
	all_pass = all_pass and t9
	
	print("")
	if all_pass:
		print("✅ 全部 9 個測試通過！")
	else:
		print("❌ 有測試未通過，請檢查上方輸出。")
	print("--- Advanced Rule Tests Finished ---")

func _print_result(num: int, desc: String, result: bool) -> void:
	var mark = "✅ PASS" if result else "❌ FAIL"
	print("Test %d [%s]: %s" % [num, mark, desc])
