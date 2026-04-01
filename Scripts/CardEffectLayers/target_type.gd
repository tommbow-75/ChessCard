class_name TargetType
extends Resource

enum Type {
	PLAYER,
	PIECE,
	CELL,
}

@export var type: Type = Type.PIECE
