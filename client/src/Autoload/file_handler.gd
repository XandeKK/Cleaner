extends Node

var canvas : SubViewportContainer
var mask_images_path : Array
var raw_images_path : Array
var current_page : int = 0

signal page_changed(text)

func is_it_image(filename : String) -> bool:
	if filename.ends_with('.png') or filename.ends_with('.jpg') or filename.ends_with('.jpeg') or filename.ends_with('.webp'):
		return true
	return false

func open() -> void:
	raw_images_path = get_all_files('/tmp/cleaner/raw')
	mask_images_path = get_all_files('/tmp/cleaner/mask')
	
	load_image_in_canvas()
	emit_signal('page_changed', str(current_page + 1) + "/" + str(raw_images_path.size()))

func load_image_in_canvas() -> void:
	canvas.load_mask_image(load_image(mask_images_path[current_page]))
	canvas.load_raw_image(load_image(raw_images_path[current_page]))

func load_image(path : String) -> ImageTexture:
	var image = Image.new()
	var texture = ImageTexture.new()

	image.load(path)
	texture.set_image(image)

	return texture

func foward() -> void:
	if current_page == raw_images_path.size() - 1 or raw_images_path.size() == 0:
		return
	
	current_page += 1
	load_image_in_canvas()
	emit_signal('page_changed', str(current_page + 1) + "/" + str(raw_images_path.size()))

func back() -> void:
	if current_page == 0:
		return
	
	current_page -= 1
	load_image_in_canvas()
	emit_signal('page_changed', str(current_page + 1) + "/" + str(raw_images_path.size()))

func get_all_files(path: String, files := []):
	var dir = DirAccess.open(path)

	if DirAccess.get_open_error() == OK:
		dir.list_dir_begin()

		var file_name = dir.get_next()

		while file_name != "":
			if dir.current_is_dir():
				files = get_all_files(dir.get_current_dir() +"/"+ file_name, files)
			else:
				if not is_it_image(file_name):
					file_name = dir.get_next()
					continue
				
				files.append(dir.get_current_dir() +"/"+ file_name)

			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access %s." % path)

	return files
