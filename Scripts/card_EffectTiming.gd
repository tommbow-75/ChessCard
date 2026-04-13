class_name CardEffectTiming
extends Resource

enum Timing {
	ONCE,
	BORN,
	SUMMON,
}

@export var timing: Timing = Timing.ONCE

func execute(_context: Dictionary) -> void:
	pass
