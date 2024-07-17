extends Control

func _draw():
	var pixel_size = get_parent().pixel_size
	var top_left = get_local_mouse_position() - Vector2(pixel_size, pixel_size)
	var rect_size = Vector2(2 * pixel_size + 1, 2 * pixel_size + 1)
	
	var rect2 : Rect2 = Rect2(top_left, rect_size)
	draw_rect(rect2, Color(Color.RED, 0.4))

func _on_gui_input(event):
	if event is InputEventMouseMotion:
		queue_redraw()
