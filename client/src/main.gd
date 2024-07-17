extends Control

@onready var mask : Mask = $MarginContainer/VBoxContainer/Control/Canvas/SubViewport/BottomCanvas/SubViewport/Mask

func _ready():
	Client.download_finished.connect(_on_download_finshed)
	FileHandler.canvas = $MarginContainer/VBoxContainer/Control/Canvas
	
	FileHandler.page_changed.connect(_on_page_changed)

func _input(event):
	if event.is_action_pressed("ui_save"):
		_on_save_pressed()
	elif event.is_action_pressed('ui_left'):
		FileHandler.back()
	elif event.is_action_pressed('ui_right'):
		FileHandler.foward()

func _on_download_finshed() -> void:
	OS.execute('unzip', ['/tmp/cleaner/mask.zip', '-d', '/tmp/cleaner/mask'])
	FileHandler.open()

func _on_ok_pressed():
	Client.url = $MarginContainer/VBoxContainer/HBoxContainer/URL.text
	Client.path = $MarginContainer/VBoxContainer/HBoxContainer/Path.text
	
	if DirAccess.dir_exists_absolute('/tmp/cleaner'):
			OS.execute('rm', ['/tmp/cleaner', '-rf'])
		
	DirAccess.make_dir_absolute('/tmp/cleaner')
	DirAccess.make_dir_absolute('/tmp/cleaner/raw')
	DirAccess.make_dir_absolute('/tmp/cleaner/mask')
	
	OS.execute('unzip', [Client.path, '-d', '/tmp/cleaner/raw'])
	Client.send_images()

func _on_redraw_pressed():
	if FileAccess.file_exists('/tmp/cleaner/mask.zip'):
		DirAccess.remove_absolute('/tmp/cleaner/mask.zip')
	
	OS.execute('/home/xande/Languages/Godot/Cleaner/zip.sh', [])
	Client.redraw()

func _on_back_pressed():
	FileHandler.back()

func _on_foward_pressed():
	FileHandler.foward()

func _on_page_changed(text) -> void:
	$MarginContainer/VBoxContainer/HBoxContainer2/HBoxContainer/Pages.text = text

func _on_save_pressed():
	var img : Image = mask.texture.get_image()
	img.save_jpg(FileHandler.mask_images_path[FileHandler.current_page])
