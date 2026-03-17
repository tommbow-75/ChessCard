class_name CardData
extends Resource

## 基礎卡牌資料結構
## 定義遊戲中卡牌的共通屬性

enum CardCategory { 
	SUMMON, 	# 召喚卡
	STRATEGY 	# 謀略卡
}

@export var id: String = ""
@export var card_name: String = ""
@export var category: CardCategory = CardCategory.STRATEGY

# 謀略點數(SP: Strategy Point) 消耗
@export var sp_cost: int = 1 
# 卡牌效果敘述
@export var effect_description: String = ""

# 未來可在此實作發動卡牌效果的虛擬函式
func execute_effect() -> void:
	pass
