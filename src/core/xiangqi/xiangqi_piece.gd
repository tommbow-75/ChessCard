class_name XiangqiPiece
extends RefCounted

enum Side { RED, BLACK }
enum PieceType { GENERAL, ADVISOR, ELEPHANT, HORSE, CHARIOT, CANNON, SOLDIER }

var side: int
var type: int
var special_effects: Array = []
var knight_leap_available: bool = false
var is_stunned: bool = false
var stun_duration: int = 0

func _init(_side: int, _type: int) -> void:
	side = _side
	type = _type
