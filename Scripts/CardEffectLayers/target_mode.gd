class_name TargetMode
extends Resource

enum Mode {
	SINGLE, # 單一格
	AREA_3X3, # 3x3 範圍
}

@export var mode: Mode = Mode.SINGLE
