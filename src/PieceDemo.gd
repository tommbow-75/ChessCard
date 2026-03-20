extends Node2D

var PIECES_RED = ["帥", "仕", "像", "俥", "傌", "炮", "兵"]
var PIECES_BLACK = ["將", "士", "象", "車", "馬", "包", "卒"]

func _ready():
	_create_pieces(PIECES_RED, Color.RED, 0)
	_create_pieces(PIECES_BLACK, Color.BLACK, 1)

func _create_pieces(piece_list: Array, piece_color: Color, row_offset: int):
	var offset_x = 100
	for i in range(piece_list.size()):
		var panel = ColorRect.new()
		panel.color = Color.WHEAT
		panel.size = Vector2(60, 60)
		panel.position = Vector2(offset_x + (i % 5) * 80, 50 + (row_offset * 180) + (i / 5) * 80)
		
		var p_label = Label.new()
		p_label.text = piece_list[i]
		p_label.add_theme_color_override("font_color", piece_color)
		p_label.add_theme_font_size_override("font_size", 40)
		p_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		p_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		p_label.size = panel.size
		p_label.position = Vector2(0, 0)
		
		panel.add_child(p_label)
		add_child(panel)
