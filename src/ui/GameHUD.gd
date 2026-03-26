extends CanvasLayer

## HUD：顯示回合、SP、士氣、CHECK 警告、重新開始按鈕

@onready var turn_label:    Label  = $Panel/VBox/TurnLabel
@onready var red_morale_label:  Label  = $Panel/VBox/RedMoraleLabel
@onready var red_sp_label:      Label  = $Panel/VBox/RedSPLabel
@onready var sep_label:         Label  = $Panel/VBox/SepLabel
@onready var black_morale_label: Label = $Panel/VBox/BlackMoraleLabel
@onready var black_sp_label:    Label  = $Panel/VBox/BlackSPLabel
@onready var status_label:  Label  = $Panel/VBox/StatusLabel
@onready var restart_btn:   Button = $Panel/VBox/RestartButton

signal restart_requested

func _ready():
	restart_btn.pressed.connect(func(): restart_requested.emit())

## 更新所有 HUD 狀態
## is_red_check / is_black_check：CHECK 狀態會在 XiangqiGameUI._draw() 上直接繪製，此處不處理
func update_state(
		current_turn: int,
		is_game_over: bool,
		winner: int,
		sp_r: int = 0,
		sp_b: int = 0,
		morale_r: int = 100,
		morale_b: int = 100
) -> void:
	if is_game_over:
		var loser_text  = "紅方" if winner == XiangqiPiece.Side.BLACK else "黑方"
		turn_label.text = "🎉 遊戲結束"
		status_label.text = loser_text + " 士氣歸零，落敗！"
		status_label.modulate = Color.YELLOW
	else:
		var side_text = "🔴 紅方" if current_turn == XiangqiPiece.Side.RED else "⚫ 黑方"
		turn_label.text = side_text + " 的回合"
		status_label.text = "請選擇棋子移動"
		status_label.modulate = Color.WHITE

	# 士氣與 SP
	red_morale_label.text  = "🔴 士氣: %d / 100" % morale_r
	red_sp_label.text      = "    SP: %d" % sp_r
	sep_label.text         = "──────────"
	black_morale_label.text = "⚫ 士氣: %d / 100" % morale_b
	black_sp_label.text    = "    SP: %d" % sp_b

	# 士氣低警示顏色
	red_morale_label.modulate   = Color.RED if morale_r <= 20 else Color.WHITE
	black_morale_label.modulate = Color.RED if morale_b <= 20 else Color.WHITE
