class_name XiangqiPiece
extends RefCounted

enum Side { RED, BLACK }
enum PieceType { GENERAL, ADVISOR, ELEPHANT, HORSE, CHARIOT, CANNON, SOLDIER }

var side: int
var type: int

## 效果積木列表（從召喚卡複製而來）
var special_effects: Array = []

## 騎士技能的一次性躍遷標記（由 KnightLeapEffect 設定）
var knight_leap_available: bool = false

func _init(_side: int, _type: int):
	side = _side
	type = _type
