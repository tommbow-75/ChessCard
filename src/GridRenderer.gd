extends Node2D

var grid_size = 50
var rows = 10
var cols = 9

func _ready():
	# Request redraw just in case
	queue_redraw()

func _draw():
	var width = (cols - 1) * grid_size
	var height = (rows - 1) * grid_size
	var offset_x = 100
	var offset_y = 100
	
	# Fill background with a board color
	draw_rect(Rect2(offset_x - 20, offset_y - 20, width + 40, height + 40), Color("dcb35c"))
	
	# Draw horizontal lines
	for r in range(rows):
		var y = offset_y + r * grid_size
		draw_line(Vector2(offset_x, y), Vector2(offset_x + width, y), Color.BLACK, 2)
	
	# Draw vertical lines
	for c in range(cols):
		var x = offset_x + c * grid_size
		if c == 0 or c == cols - 1:
			draw_line(Vector2(x, offset_y), Vector2(x, offset_y + height), Color.BLACK, 2)
		else:
			# Chu River Han Border (Middle gap)
			draw_line(Vector2(x, offset_y), Vector2(x, offset_y + 4 * grid_size), Color.BLACK, 2)
			draw_line(Vector2(x, offset_y + 5 * grid_size), Vector2(x, offset_y + height), Color.BLACK, 2)
			
	# Draw Palace diagonals (Top and Bottom)
	draw_line(Vector2(offset_x + 3 * grid_size, offset_y), Vector2(offset_x + 5 * grid_size, offset_y + 2 * grid_size), Color.BLACK, 2)
	draw_line(Vector2(offset_x + 5 * grid_size, offset_y), Vector2(offset_x + 3 * grid_size, offset_y + 2 * grid_size), Color.BLACK, 2)
	
	draw_line(Vector2(offset_x + 3 * grid_size, offset_y + 7 * grid_size), Vector2(offset_x + 5 * grid_size, offset_y + 9 * grid_size), Color.BLACK, 2)
	draw_line(Vector2(offset_x + 5 * grid_size, offset_y + 7 * grid_size), Vector2(offset_x + 3 * grid_size, offset_y + 9 * grid_size), Color.BLACK, 2)
