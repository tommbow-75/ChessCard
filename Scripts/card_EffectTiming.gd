class_name CardEffectTiming
extends Resource


# 定義這三個發動規則（時機）
enum Timing { 
	ONCE,   # 一次性
	BORN, # 天生
	SUMMON  # 召喚
}

# 讓這個卡牌的發動時機可以在編輯器下拉選單中被選擇
@export var timing: Timing = Timing.ONCE

# 實際的效果內容（留給子類別去實作）
# 傳入 context (字典) 可以把當下的遊戲狀態、發起者、目標都傳進來
func execute(context: Dictionary) -> void:
    pass