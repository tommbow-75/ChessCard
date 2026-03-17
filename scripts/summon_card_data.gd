class_name SummonCardData
extends CardData

## 召喚卡資料結構
## 專用於召喚象棋棋子的卡牌

@export var summon_type: ChessPieceData.PieceType = ChessPieceData.PieceType.SOLDIER
@export var summon_morale_value: int = 5

func _init() -> void:
	category = CardCategory.SUMMON

## 可自動根據召喚兵種補齊對應的士氣值
func setup_default_morale() -> void:
	match summon_type:
		ChessPieceData.PieceType.GENERAL:
			summon_morale_value = 30
		ChessPieceData.PieceType.ADVISOR, ChessPieceData.PieceType.ELEPHANT, ChessPieceData.PieceType.CHARIOT, ChessPieceData.PieceType.HORSE, ChessPieceData.PieceType.CANNON:
			summon_morale_value = 10
		ChessPieceData.PieceType.SOLDIER:
			summon_morale_value = 5
