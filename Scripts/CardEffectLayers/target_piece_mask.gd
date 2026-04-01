class_name TargetPieceMask
extends Resource

const GENERAL := 1
const ADVISOR := 2
const ELEPHANT := 4
const HORSE := 8
const CHARIOT := 16
const CANNON := 32
const SOLDIER := 64
const DEFAULT_MASK := 127  # 預設全選（不含空格）

@export_flags("General", "Advisor", "Elephant", "Horse", "Chariot", "Cannon", "Soldier")
var mask: int = DEFAULT_MASK

func matches(piece_type: int) -> bool:
	var bit := 0
	match piece_type:
		XiangqiPiece.PieceType.GENERAL:
			bit = GENERAL
		XiangqiPiece.PieceType.ADVISOR:
			bit = ADVISOR
		XiangqiPiece.PieceType.ELEPHANT:
			bit = ELEPHANT
		XiangqiPiece.PieceType.HORSE:
			bit = HORSE
		XiangqiPiece.PieceType.CHARIOT:
			bit = CHARIOT
		XiangqiPiece.PieceType.CANNON:
			bit = CANNON
		XiangqiPiece.PieceType.SOLDIER:
			bit = SOLDIER
		_:
			return false
	return (mask & bit) != 0
