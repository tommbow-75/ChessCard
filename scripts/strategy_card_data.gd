class_name StrategyCardData
extends CardData

@export var special_effects: Array[StrategyEffectTiming] = []

func _init() -> void:
	category = CardCategory.STRATEGY
