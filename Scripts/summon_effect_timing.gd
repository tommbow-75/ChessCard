class_name SummonEffectTiming
extends Resource

enum Timing {
	SUMMON,
	BORN,
	ONCE,
}

@export var timing: Timing = Timing.SUMMON

func execute(_context: Dictionary) -> void:
	pass
