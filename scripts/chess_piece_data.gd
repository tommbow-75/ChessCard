class_name ChessPieceData
extends Resource

## 中國象棋棋子資料結構
## 定義棋子的基本屬性與士氣值(Morale)

enum PieceType { 
	GENERAL, 	# 帥/將
	ADVISOR, 	# 仕/士
	ELEPHANT, 	# 相/象
	CHARIOT, 	# 俥/車
	HORSE, 		# 傌/馬
	CANNON, 	# 炮/砲
	SOLDIER 	# 兵/卒
}

enum Camp {
	RED,
	BLACK
}

@export var id: String = ""
@export var piece_name: String = ""
@export var type: PieceType = PieceType.SOLDIER
@export var camp: Camp = Camp.RED
@export var morale_cost: int = 5 # 預設為兵卒的士氣值

## 根據棋子種類初始化預設的士氣值
func setup_default_morale() -> void:
	match type:
		PieceType.GENERAL:
			morale_cost = 30
		PieceType.ADVISOR, PieceType.ELEPHANT, PieceType.CHARIOT, PieceType.HORSE, PieceType.CANNON:
			morale_cost = 10
		PieceType.SOLDIER:
			morale_cost = 5
