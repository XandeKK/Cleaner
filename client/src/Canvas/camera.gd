extends Camera2D

var is_panning : bool = false
var initial_touch : Vector2
var initial_camera_position : Vector2

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.is_pressed():
			zoom_out()
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.is_pressed():
			zoom_in()
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.is_pressed():
				is_panning = true
				initial_touch = event.position
				initial_camera_position = position
			elif event.is_released():
				is_panning = false

	elif event is InputEventMouseMotion and is_panning:
		pan(event)

func zoom_in():
	var new_zoom = zoom + Vector2(0.1, 0.1)
	if new_zoom.x <= 1.5 and new_zoom.y <= 1.5:
		zoom = new_zoom

func zoom_out():
	var new_zoom = zoom - Vector2(0.1, 0.1)
	if new_zoom.x >= 0.2 and new_zoom.y >= 0.2:
		zoom = new_zoom

func pan(event):
	var delta = (initial_touch - event.position) / zoom
	position = initial_camera_position + delta
	# Não sei se é uma boa ideia colocar um limite aqui, então vou deixar sem limite nenhum

func back_to_center() -> void:
	position = Vector2.ZERO
