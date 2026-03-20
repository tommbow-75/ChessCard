extends CanvasLayer

## HUD：顯示回合、勝利訊息、重新開始按鈕

@onready var turn_label: Label   = $Panel/VBox/TurnLabel
@onready var status_label: Label = $Panel/VBox/StatusLabel
@onready var restart_btn: Button = $Panel/VBox/RestartButton

signal restart_requested

func _ready():
	restart_btn.pressed.connect(func(): restart_requested.emit())

func update_state(current_turn: int, is_game_over: bool, winner: int):
	if is_game_over:
		var winner_text = "紅方" if winner == XiangqiPiece.Side.RED else "黑方"
		turn_label.text = "🎉 遊戲結束"
		status_label.text = winner_text + " 獲勝！"
		status_label.modulate = Color.YELLOW
	else:
		var side_text = "🔴 紅方" if current_turn == XiangqiPiece.Side.RED else "⚫ 黑方"
		turn_label.text = side_text + " 的回合"
		status_label.text = "請選擇棋子移動"
		status_label.modulate = Color.WHITE
