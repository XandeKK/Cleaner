extends Control
class_name Mask

var history_redo : Array
var history_undo : Array

var image_texture : ImageTexture : set = set_image_texture
var pixel_size : int = 10
var white : bool = true
var last_mouse_position : Vector2 = Vector2(-1, -1)
var is_drawing : bool = false
var pos : Vector2 = Vector2.ZERO
var can_draw_texture : bool = false
var bucket : bool = false
var line : bool = false

var line_start : Vector2 = Vector2()
var line_end : Vector2 = Vector2()
var drawing_line : bool = false
var can_draw_line : bool = false

func _draw():
	if can_draw_texture:
		draw_texture(image_texture, Vector2.ZERO)
		can_draw_texture = false
	
	if can_draw_line:
		draw_line(line_start, line_end, Color.WHITE if white else Color.BLACK, pixel_size, true)
		can_draw_line = false
	
	if not is_drawing or pos == last_mouse_position:
		return

	if last_mouse_position != Vector2(-1, -1):
		var distSqr = last_mouse_position.distance_squared_to(pos)
		if distanceTooBig(distSqr):
			putBrushDot(pos)
			draw_interpolated(distSqr)
		else:
			putBrushDot(pos)
		last_mouse_position = pos
	else:
		last_mouse_position = pos
		putBrushDot(pos)

func distanceTooBig(dist2):
	return dist2 > max_dist_btwn_dots() * max_dist_btwn_dots()

func draw_interpolated(distSqr):
	var dirVector : Vector2 = last_mouse_position.direction_to(pos)
	dirVector = dirVector * max_dist_btwn_dots()
	var interpVector = Vector2(dirVector)
	while interpVector.length_squared() < distSqr:
		putBrushDot(last_mouse_position + interpVector)
		interpVector += dirVector

func max_dist_btwn_dots():
	return pixel_size / 3.0

func putBrushDot(pos):
	draw_circle(pos, pixel_size, Color.WHITE if white else Color.BLACK)

func _process(delta):
	pos = get_local_mouse_position()
	if is_drawing or can_draw_line:
		queue_redraw()

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if bucket:
				bucket_fill(event.position, Color.WHITE if white else Color.BLACK)
			elif line:
				line_start = event.position
				drawing_line = true
			else:
				is_drawing =  true
			history_undo.append(get_parent().get_texture().get_image())
			history_redo.clear()
		else:
			if drawing_line:
				line_end = event.position
				can_draw_line = true
				drawing_line = false
			else:
				is_drawing =  false
				last_mouse_position = Vector2(-1, -1)

func redo() -> void:
	if history_redo.is_empty():
		Notification.message("Can't use redo")
		return
	
	var img : Image = history_redo.pop_back()
	history_undo.append(get_parent().get_texture().get_image())
	set_image_texture(ImageTexture.create_from_image(img))

func undo() -> void:
	if history_undo.is_empty():
		Notification.message("Can't use undo")
		return
	
	var img : Image = history_undo.pop_back()
	history_redo.append(get_parent().get_texture().get_image())
	set_image_texture(ImageTexture.create_from_image(img))

func _on_black_toggled(toggled_on):
	white = not toggled_on

func _on_pixel_size_value_changed(value : float):
	pixel_size = value

func set_image_texture(value : ImageTexture) -> void:
	image_texture = value
	can_draw_texture = true
	get_parent().render_target_clear_mode = SubViewport.CLEAR_MODE_ONCE
	queue_redraw()

func bucket_fill(position: Vector2, color: Color) -> void:
	var img : Image = get_parent().get_texture().get_image()

	var target_color : Color = img.get_pixelv(position)
	if target_color == color:
		return
	
	flood_fill(img, position, target_color, color)
	
	set_image_texture(ImageTexture.create_from_image(img))

func flood_fill(image: Image, position: Vector2, target_color: Color, fill_color: Color) -> void:
	var width = image.get_width()
	var height = image.get_height()

	var stack = [position]
	while stack.size() > 0:
		var point = stack.pop_back()
		var x = int(point.x)
		var y = int(point.y)

		if x < 0 or x >= width or y < 0 or y >= height:
			continue

		if image.get_pixel(x, y) == target_color:
			image.set_pixel(x, y, fill_color)
			stack.append(Vector2(x + 1, y))
			stack.append(Vector2(x - 1, y))
			stack.append(Vector2(x, y + 1))
			stack.append(Vector2(x, y - 1))

func _on_bucket_toggled(toggled_on):
	bucket = toggled_on

func _on_line_toggled(toggled_on):
	line = toggled_on

func _draw_line(start: Vector2, end: Vector2, color: Color) -> void:
	var img : Image = get_parent().get_texture().get_image()
	
	var dx = abs(end.x - start.x)
	var dy = abs(end.y - start.y)
	var sx = 1 if start.x < end.x else -1
	var sy = 1 if start.y < end.y else -1
	var err = dx - dy

	while true:
		img.set_pixelv(start, color)

		if start == end:
			break

		var e2 = 2 * err
		if e2 > -dy:
			err -= dy
			start.x += sx
		if e2 < dx:
			err += dx
			start.y += sy

	set_image_texture(ImageTexture.create_from_image(img))
