class_name ForbidCaptureNextMoveEffect
extends StrategyEffectTiming

const FORBID_ALL_TARGETS := -1

@export var timing: int = 1
@export var forbidden_target: int = FORBID_ALL_TARGETS

## 謀略用：下一著走子若會吃子則不合法（僅消費一次）
## 與「需選格」效果併用時請放在 special_effects[1]，[0] 負責目標選取

func _init() -> void:
	target_type = TargetType.new()
	target_type.type = TargetType.Type.PLAYER
	effect_target = EffectTarget.new()
	piece_mask = TargetPieceMask.new()
	target_mode = TargetMode.new()
	target_mode.mode = TargetMode.Mode.NONE

func applies_to_target(piece_type: int) -> bool:
	return forbidden_target == FORBID_ALL_TARGETS or forbidden_target == piece_type

func execute(context: Dictionary) -> void:
	var game = context.get("game")
	if game == null:
		return
	game.pending_extra_move_forbid_capture = true
	game.pending_extra_move_forbidden_target = forbidden_target
