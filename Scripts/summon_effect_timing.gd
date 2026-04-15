class_name SummonEffectTiming
extends Resource

enum Timing {
	SUMMON,
	BORN,
	ONCE,
}

@export var timing: Timing = Timing.SUMMON

## 回傳此效果目前是否「可發動」。
## 如果為 false，UI 雖然會顯示描述，但「發動」按鈕會變為灰色或不允許點擊。
## 預設為 true。子類別可覆寫此邏輯（例如火焰車判斷是否完成第一步且未吃子）。
func can_execute(_context: Dictionary) -> bool:
	return true

func execute(_context: Dictionary) -> void:
	pass

## 在移動完成後進行清理回調。
func on_move_completed(_context: Dictionary) -> void:
	pass
