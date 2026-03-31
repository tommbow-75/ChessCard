class_name SummonEffectTiming
extends Resource


# 定義這三個發動規則（時機）
enum Timing { 
	SUMMON,  # 召喚時觸發
	BORN,    # 棋子存在棋盤時，持續觸發
	ONCE,    # 棋子存在棋盤時，能夠發動1次，用完即失效
}

# 讓這個卡牌的發動時機可以在編輯器下拉選單中被選擇
@export var timing: Timing = Timing.SUMMON

# 實際的效果內容（留給子類別去實作）
# 傳入 context (字典) 可以把當下的遊戲狀態、發起者、目標都傳進來
func execute(_context: Dictionary) -> void:
	pass
