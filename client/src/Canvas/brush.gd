extends Control
class_name Brush

@onready var texture_rect : TextureRect = get_parent()

var polygon_mode : bool = false
var polygon_points : Array = []
var pixel_size : int = 10
var white : bool = true
var last_mouse_position : Vector2 = Vector2(-1, -1)
var is_drawing : bool = false
var pending_updates : bool = false

func _draw():
	if polygon_points.size() >= 3:
		draw_colored_polygon(polygon_points, Color(Color.RED, 0.3))

func _input(event):
	if polygon_mode:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				add_polygon()
				queue_redraw()
		elif event.is_action_pressed("ui_accept"):
			end_polygon()
			queue_redraw()
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_drawing =  true
		else:
			is_drawing =  false
			last_mouse_position = Vector2(-1,-1)
	if event is InputEventMouseMotion and is_drawing:
		var mouse_position : Vector2 = get_local_mouse_position()
		
		if last_mouse_position.x >= 0 and last_mouse_position.y >= 0:
			var distance = mouse_position.distance_to(last_mouse_position)
			var steps = int(distance)
			
			for i in range(steps):
				var interpolated_position = last_mouse_position.lerp(mouse_position, float(i) / steps)
				_draw_circle(interpolated_position)

		last_mouse_position = mouse_position

		_draw_circle(mouse_position)
		pending_updates = true

func _process(_delta):
	if pending_updates:
		texture_rect.texture.update(texture_rect.image)
		
		pending_updates = false

func _draw_circle(center: Vector2):
	var top_left = center - Vector2(pixel_size, pixel_size)
	var rect_size = Vector2(2 * pixel_size + 1, 2 * pixel_size + 1)
	texture_rect.image.fill_rect(Rect2(top_left, rect_size), Color.WHITE if white else Color.BLACK)

func _on_black_toggled(toggled_on):
	white = not toggled_on

func _on_pixel_size_value_changed(value : float):
	pixel_size = value

func add_polygon():
	last_mouse_position = get_local_mouse_position()
	polygon_points.append(last_mouse_position)

func end_polygon():
	draw_filled_polygon(polygon_points, Color.WHITE if white else Color.BLACK)
	polygon_points.clear()

func draw_filled_polygon(points: Array, color: Color):
	var min_x = points[0].x
	var max_x = points[0].x
	var min_y = points[0].y
	var max_y = points[0].y
	
	for p in points:
		if p.x < min_x: min_x = p.x
		if p.x > max_x: max_x = p.x
		if p.y < min_y: min_y = p.y
		if p.y > max_y: max_y = p.y
	
	for y in range(min_y, max_y + 1):
		var intersections = []
		
		for i in range(points.size()):
			var j = (i + 1) % points.size()
			
			var p1 = points[i]
			var p2 = points[j]
			
			if p1.y == p2.y:
				continue
			
			if y >= min(p1.y, p2.y) and y <= max(p1.y, p2.y):
				var x_inter = int(p1.x + (y - p1.y) * (p2.x - p1.x) / (p2.y - p1.y))
				intersections.append(x_inter)
		
		intersections.sort()
		
		for i in range(0, intersections.size() - 1, 2):
			var start_x = max(min_x, intersections[i])
			var end_x = min(max_x, intersections[i + 1])
			
			for x in range(start_x, end_x + 1):
				texture_rect.image.set_pixel(x, y, color)
	
	pending_updates = true

func _on_polygon_toggled(toggled_on):
	polygon_mode = toggled_on
	if not polygon_mode:
		polygon_points.clear()
