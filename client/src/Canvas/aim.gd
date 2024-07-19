extends Control

@export var parent : Mask

func _draw():
	var pixel_size = parent.pixel_size
	draw_circle(get_global_mouse_position(), pixel_size, Color(Color.RED, 0.4))

func _process(delta):
	queue_redraw()
