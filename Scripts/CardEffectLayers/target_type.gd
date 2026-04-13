class_name TargetType
extends Resource

enum Type {
	PLAYER,  # 玩家數值
	PIECE,   # 棋子
	CELL,    # 棋盤格
}

@export var type: Type = Type.PIECE
