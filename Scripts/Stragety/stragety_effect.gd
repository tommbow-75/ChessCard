class_name StragetyEffect
extends Resource

## 目標選取類型
enum TargetType {
	NONE,                       # 不需目標（直接發動）
	SINGLE_ENEMY_NON_GENERAL,   # 單一非將帥的敵方棋子
	AREA_3X3_ANY,               # 任一格子（九宮格範圍）
	ANY_NON_GENERAL,            # 任何非將帥棋子
	ANY_SOLDIER,                # 任何兵卒
}

## 告知 UI 這張卡的效果需要什麼目標
@export var target_type: TargetType = TargetType.NONE

## 判斷特定格子的目標對此效果是否合法
## context: {"game": XiangqiGame, "caster_side": Side}
func is_valid_target(_board_pos: Vector2i, _context: Dictionary) -> bool:
	return true

## 實際執行效果
## context: {"game": XiangqiGame, "caster_side": Side}, 以及可選的 "target_pos": Vector2i
func execute(_context: Dictionary) -> void:
	pass
