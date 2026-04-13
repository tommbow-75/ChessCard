extends Node2D

## CardHandPanel：管理底部手牌列，水平排列 CardView 節點
## 支援 SummonCardData 與 StrategyCardData 兩種卡牌類型

const CardViewScript = preload("res://src/ui/CardView.gd")
const CARD_W     := 180.0
const CARD_H     := 260.0
const CARD_GAP   := 16.0
const BOTTOM_PAD := 8.0

signal card_selected(card: CardData)
signal card_played(card: CardData)

var _card_resources: Array = []
var _card_nodes:    Array = []
var _selected_idx:  int   = -1
var _current_sp:    int   = 0

## 接受 Array[CardData] 並更新當前 SP 狀態
func set_hand(cards: Array, sp: int = 0) -> void:
	_current_sp = sp
	_card_resources = cards
	_selected_idx = -1
	
	# 清除舊卡牌
	for node in _card_nodes:
		node.queue_free()
	_card_nodes.clear()

	if cards.is_empty():
		return

	var total_w = cards.size() * CARD_W + (cards.size() - 1) * CARD_GAP
	var start_x = (get_viewport_rect().size.x - total_w) * 0.5
	var card_y  = get_viewport_rect().size.y - CARD_H - BOTTOM_PAD

	for i in range(cards.size()):
		var card = cards[i]
		var view = CardViewScript.new()
		add_child(view)
		view.position = Vector2(start_x + i * (CARD_W + CARD_GAP), card_y)
		view.can_afford = (sp >= card.sp_cost)

		if card is StrategyCardData:
			view.setup_strategy(card)
		elif card is SummonCardData:
			view.setup(card)

		_card_nodes.append(view)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var clicked_idx = -1
		for i in range(_card_nodes.size()):
			var node = _card_nodes[i]
			var rect = Rect2(node.position, Vector2(CARD_W, CARD_H))
			if rect.has_point(get_local_mouse_position()):
				clicked_idx = i
				break
		
		_handle_card_click(clicked_idx)

func _handle_card_click(idx: int) -> void:
	if idx == -1:
		# 點擊空白處，取消選中
		_clear_selection()
		return

	if idx == _selected_idx:
		# 第二次點擊：出牌
		var card = _card_resources[idx]
		if _current_sp >= card.sp_cost:
			card_played.emit(card)
			_clear_selection()
	else:
		# 第一次點擊：選中
		_selected_idx = idx
		_update_visuals()
		card_selected.emit(_card_resources[idx])

func _clear_selection() -> void:
	_selected_idx = -1
	_update_visuals()

func _update_visuals() -> void:
	for i in range(_card_nodes.size()):
		var node = _card_nodes[i]
		node.is_selected = (i == _selected_idx)
		node.queue_redraw()
