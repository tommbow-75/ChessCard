@tool
extends EditorScript

func _run():
	print("--- Running Xiangqi Basic Rule Tests ---")
	
	var game = XiangqiGame.new()
	game.setup_standard_board()
	
	print("Initial State - Turn: RED")
	
	# Test 1: Red Cannon Move (Valid)
	var move1 = game.move_piece(Vector2i(1, 7), Vector2i(4, 7))
	print("Expected true, Test 1 Red move Cannon (1,7) to (4,7): ", move1)
	
	# Test 2: Red Turn Again (Invalid, should be Black's turn)
	var move2 = game.move_piece(Vector2i(7, 7), Vector2i(4, 7))
	print("Expected false, Test 2 Red moves out of turn: ", move2)
	
	# Test 3: Black Horse move (Valid)
	var move3 = game.move_piece(Vector2i(1, 0), Vector2i(2, 2))
	print("Expected true, Test 3 Black move Horse (1,0) to (2,2): ", move3)
	
	# Test 4: Red Chariot invalid move (Blocked)
	var move4 = game.move_piece(Vector2i(0, 9), Vector2i(0, 7))
	print("Expected false, Test 4 Red move Chariot (0,9) to (0,7) [Blocked]: ", move4)
	
	print("--- All tests finished ---")
