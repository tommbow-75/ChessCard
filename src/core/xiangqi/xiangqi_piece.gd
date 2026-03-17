class_name XiangqiPiece
extends RefCounted

enum Side { RED, BLACK }
enum PieceType { GENERAL, ADVISOR, ELEPHANT, HORSE, CHARIOT, CANNON, SOLDIER }

var side: int
var type: int

func _init(_side: int, _type: int):
	side = _side
	type = _type
