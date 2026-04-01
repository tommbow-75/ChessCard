@tool
extends EditorScript

func _run() -> void:
	print("--- Running Advanced Rule Tests ---")

	var game = XiangqiGame.new()
	game.setup_standard_board()

	var all_pass := true

	game.start_turn()
	var t1 = (game.sp_red == 1)
	_print_result(1, "start turn gives RED +1 SP", t1)
	all_pass = all_pass and t1

	var red_soldier = XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.SOLDIER)
	var black_soldier = XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.SOLDIER)
	game.board.set_piece(Vector2i(4, 5), red_soldier)
	game.board.set_piece(Vector2i(4, 4), black_soldier)
	var sp_before = game.sp_red
	game.move_piece(Vector2i(4, 5), Vector2i(4, 4))
	var t2 = (game.sp_red == sp_before + 1)
	_print_result(2, "capture soldier gives +1 SP", t2)
	all_pass = all_pass and t2
	game.setup_standard_board()

	game.start_turn()
	var red_chariot = XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.CHARIOT)
	var black_chariot = XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.CHARIOT)
	game.board.set_piece(Vector2i(0, 5), red_chariot)
	game.board.set_piece(Vector2i(0, 3), black_chariot)
	var sp_before_3 = game.sp_red
	game.move_piece(Vector2i(0, 5), Vector2i(0, 3))
	var t3 = (game.sp_red == sp_before_3 + 2)
	_print_result(3, "capture chariot gives +2 SP", t3)
	all_pass = all_pass and t3
	game.setup_standard_board()

	var red_r = XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.CHARIOT)
	var black_s = XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.SOLDIER)
	game.board.set_piece(Vector2i(0, 5), red_r)
	game.board.set_piece(Vector2i(0, 4), black_s)
	var morale_before = game.morale_black
	game.move_piece(Vector2i(0, 5), Vector2i(0, 4))
	var t4 = (game.morale_black == morale_before - 5)
	_print_result(4, "capture lowers enemy morale by 5", t4)
	all_pass = all_pass and t4
	game.setup_standard_board()

	var card = SummonCardData.new()
	card.sp_cost = 10
	var t5 = (game.summon_piece(card, Vector2i(0, 9), XiangqiPiece.Side.RED) == false)
	_print_result(5, "summon fails when SP is insufficient", t5)
	all_pass = all_pass and t5

	game.sp_red = 99
	card.sp_cost = 1
	var t6 = (game.summon_piece(card, Vector2i(0, 9), XiangqiPiece.Side.RED) == false)
	_print_result(6, "summon fails on occupied cell", t6)
	all_pass = all_pass and t6

	game.sp_black = 99
	var t7 = (game.summon_piece(card, Vector2i(4, 5), XiangqiPiece.Side.BLACK) == false)
	_print_result(7, "black summon outside legal zone fails", t7)
	all_pass = all_pass and t7
	game.setup_standard_board()

	var trash_cannon = XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.CANNON)
	var forbid_capture = ForbidCaptureNextMoveEffect.new()
	forbid_capture.forbidden_target = XiangqiPiece.PieceType.GENERAL
	trash_cannon.special_effects.append(forbid_capture)
	game.board.set_piece(Vector2i(4, 5), trash_cannon)
	var black_g = XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.GENERAL)
	game.board.set_piece(Vector2i(4, 0), black_g)
	var blocker = XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.SOLDIER)
	game.board.set_piece(Vector2i(4, 3), blocker)
	var t8 = (XiangqiRuleVerifier.is_valid_move(game.board, Vector2i(4, 5), Vector2i(4, 0)) == false)
	_print_result(8, "forbid capture effect blocks general capture", t8)
	all_pass = all_pass and t8
	game.setup_standard_board()

	var fierce_gen = XiangqiPiece.new(XiangqiPiece.Side.RED, XiangqiPiece.PieceType.GENERAL)
	var restore_eff = RestoreOnCaptureEffect.new()
	restore_eff.restore_amount = 2
	fierce_gen.special_effects.append(restore_eff)
	game.board.set_piece(Vector2i(4, 9), fierce_gen)
	var enemy_s = XiangqiPiece.new(XiangqiPiece.Side.BLACK, XiangqiPiece.PieceType.SOLDIER)
	game.board.set_piece(Vector2i(4, 8), enemy_s)
	game.board.remove_piece(Vector2i(4, 9))
	game.board.set_piece(Vector2i(4, 8), enemy_s)
	game.board.set_piece(Vector2i(4, 9), fierce_gen)
	game.morale_red = 80
	var morale_before_9 = game.morale_red
	game.move_piece(Vector2i(4, 9), Vector2i(4, 8))
	var t9 = (game.morale_red >= morale_before_9)
	_print_result(9, "restore_on_capture recovers morale", t9)
	all_pass = all_pass and t9

	print("")
	if all_pass:
		print("All 9 advanced rule tests passed.")
	else:
		print("Some advanced rule tests failed.")
	print("--- Advanced Rule Tests Finished ---")

func _print_result(num: int, desc: String, result: bool) -> void:
	var mark = "PASS" if result else "FAIL"
	print("Test %d [%s]: %s" % [num, mark, desc])
