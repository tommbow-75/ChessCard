class_name ChessPieceData
extends Resource

enum PieceType {
	GENERAL,
	ADVISOR,
	ELEPHANT,
	HORSE,
	CHARIOT,
	CANNON,
	SOLDIER,
}

enum Camp {
	RED,
	BLACK,
}

@export var id: String = ""
@export var piece_name: String = ""
@export var type: PieceType = PieceType.SOLDIER
@export var camp: Camp = Camp.RED
@export var morale_cost: int = 5

func setup_default_morale() -> void:
	match type:
		PieceType.GENERAL:
			morale_cost = 30
		PieceType.ADVISOR, PieceType.ELEPHANT, PieceType.CHARIOT, PieceType.HORSE, PieceType.CANNON:
			morale_cost = 10
		PieceType.SOLDIER:
			morale_cost = 5
