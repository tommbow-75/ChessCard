class_name CardData
extends Resource

enum CardCategory {
	SUMMON,
	STRATEGY,
}

@export var id: String = ""
@export var card_name: String = ""
@export var category: CardCategory = CardCategory.STRATEGY
@export var sp_cost: int = 1
@export var effect_description: String = ""

func execute_effect() -> void:
	pass
