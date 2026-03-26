extends Node2D

## CardHandPanel：管理底部手牌列，水平排列 CardView 節點
## 使用 Node2D，卡牌以固定間距直接排列在畫面底部

const CardViewScript = preload("res://src/ui/CardView.gd")
const CARD_W     := 180.0
const CARD_H     := 260.0
const CARD_GAP   := 16.0
const BOTTOM_PAD := 8.0

var _card_nodes: Array = []

func set_hand(cards: Array) -> void:
	# 清除舊卡牌
	for node in _card_nodes:
		node.queue_free()
	_card_nodes.clear()
	var total_w = cards.size() * CARD_W + (cards.size() - 1) * CARD_GAP
	var start_x = (get_viewport_rect().size.x - total_w) * 0.5
	var card_y  = get_viewport_rect().size.y - CARD_H - BOTTOM_PAD

	for i in range(cards.size()):
		var view = CardViewScript.new()
		add_child(view)
		view.position = Vector2(start_x + i * (CARD_W + CARD_GAP), card_y)
		view.setup(cards[i])
		_card_nodes.append(view)
