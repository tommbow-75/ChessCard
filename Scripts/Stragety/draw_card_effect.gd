class_name DrawCardEffect
extends StragetyEffect

@export var draw_amount: int = 1

func _init() -> void:
	target_type = TargetType.NONE

func execute(_context: Dictionary) -> void:
	print("【謀略發動】抽 ", draw_amount, " 張卡！ (牌庫系統未實作)")
