class_name SummonCardData
extends CardData

@export var summon_type: ChessPieceData.PieceType = ChessPieceData.PieceType.SOLDIER
@export var morale_value: int = 5
@export var special_effects: Array[Resource] = []

func _init() -> void:
	category = CardCategory.SUMMON

func setup_default_morale() -> void:
	match summon_type:
		ChessPieceData.PieceType.GENERAL:
			morale_value = 30
		ChessPieceData.PieceType.ADVISOR, ChessPieceData.PieceType.ELEPHANT, ChessPieceData.PieceType.CHARIOT, ChessPieceData.PieceType.HORSE, ChessPieceData.PieceType.CANNON:
			morale_value = 10
		ChessPieceData.PieceType.SOLDIER:
			morale_value = 5
