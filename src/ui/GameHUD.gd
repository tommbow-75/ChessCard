class_name GameHUD
extends CanvasLayer

@onready var turn_label: Label = $Panel/VBox/TurnLabel
@onready var red_morale_label: Label = $Panel/VBox/RedMoraleLabel
@onready var red_sp_label: Label = $Panel/VBox/RedSPLabel
@onready var sep_label: Label = $Panel/VBox/SepLabel
@onready var black_morale_label: Label = $Panel/VBox/BlackMoraleLabel
@onready var black_sp_label: Label = $Panel/VBox/BlackSPLabel
@onready var action_label: Label = $Panel/VBox/ActionLabel
@onready var status_label: Label = $Panel/VBox/StatusLabel
@onready var end_turn_btn: Button = $Panel/VBox/EndTurnButton
@onready var restart_btn: Button = $Panel/VBox/RestartButton

signal restart_requested
signal end_turn_requested

func _ready() -> void:
	restart_btn.pressed.connect(func(): restart_requested.emit())
	end_turn_btn.pressed.connect(func(): end_turn_requested.emit())
	
	# 強制設定中文以避開編碼或場景文字遺失問題
	restart_btn.text = "🔄 重啟遊戲"
	end_turn_btn.text = "🏁 結束回合"

func update_state(
		current_turn: int,
		is_game_over: bool,
		winner: int,
		sp_r: int = 0,
		sp_b: int = 0,
		morale_r: int = 100,
		morale_b: int = 100,
		actions_used: int = 0,
		move_actions: int = 0,
		card_actions: int = 0,
		can_end_turn_now: bool = false
) -> void:
	if is_game_over:
		var winner_text = "紅方" if winner == XiangqiPiece.Side.RED else "黑方"
		turn_label.text = "遊戲結束"
		status_label.text = winner_text + " 獲勝"
		status_label.modulate = Color.YELLOW
	else:
		var side_text = "紅方" if current_turn == XiangqiPiece.Side.RED else "黑方"
		turn_label.text = side_text + " 回合"
		status_label.text = "按下結束回合才會換邊"
		status_label.modulate = Color.WHITE

	red_morale_label.text = "紅方士氣: %d / 100" % morale_r
	red_sp_label.text = "紅方 SP: %d" % sp_r
	sep_label.text = "----------------"
	black_morale_label.text = "黑方士氣: %d / 100" % morale_b
	black_sp_label.text = "黑方 SP: %d" % sp_b
	action_label.text = "本回合動作 %d/%d  |  出牌 %d  |  走子 %d" % [actions_used, XiangqiGame.MAX_ACTIONS_PER_TURN, card_actions, move_actions]

	red_morale_label.modulate = Color.RED if morale_r <= 20 else Color.WHITE
	black_morale_label.modulate = Color.RED if morale_b <= 20 else Color.WHITE
	end_turn_btn.disabled = is_game_over or not can_end_turn_now
