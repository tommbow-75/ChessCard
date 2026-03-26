class_name StrategyCardData
extends CardData

@export var special_effects: Array[StragetyEffect] = []

func _init() -> void:
	category = CardCategory.STRATEGY
