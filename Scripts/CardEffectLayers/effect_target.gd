class_name EffectTarget
extends Resource

enum Target {
	SELF,   # 己方
	ENEMY,  # 敵方
	ANY,    # 雙方
}

@export var target: Target = Target.ENEMY
