class_name XiangqiGame
extends RefCounted

var board: XiangqiBoard = XiangqiBoard.new()
var current_turn: int = XiangqiPiece.Side.RED
var is_game_over: bool = false
var winner: int = -1

func setup_standard_board():
	board.clear()
	current_turn = XiangqiPiece.Side.RED
	is_game_over = false
	winner = -1
	
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

func move_piece(from_pos: Vector2i, to_pos: Vector2i) -> bool:
	if is_game_over:
		return false
		
	var piece = board.get_piece(from_pos)
	if piece == null or piece.side != current_turn:
		return false
		
	if not XiangqiRuleVerifier.is_valid_move(board, from_pos, to_pos):
		return false
		
	var target = board.get_piece(to_pos)
	if target != null and target.type == XiangqiPiece.PieceType.GENERAL:
		is_game_over = true
		winner = current_turn
		
	board.remove_piece(from_pos)
	board.set_piece(to_pos, piece)
	
	if not is_game_over:
		current_turn = XiangqiPiece.Side.BLACK if current_turn == XiangqiPiece.Side.RED else XiangqiPiece.Side.RED

	return true
