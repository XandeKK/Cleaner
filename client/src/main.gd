extends Control

@onready var black_check : CheckButton = $MarginContainer/VBoxContainer/HBoxContainer2/Black
@onready var bucket_check : CheckButton = $MarginContainer/VBoxContainer/HBoxContainer2/Bucket
@onready var sub_viewport_mask : SubViewport = $MarginContainer/VBoxContainer/Control/Canvas/SubViewport/BottomCanvas/SubViewport/SubViewportContainer/SubViewport
@onready var mask : Mask = $MarginContainer/VBoxContainer/Control/Canvas/SubViewport/BottomCanvas/SubViewport/SubViewportContainer/SubViewport/Mask

func _ready():
	Notification.notification_body = $NotificationBody
	
	Client.download_finished.connect(_on_download_finshed)
	FileHandler.canvas = $MarginContainer/VBoxContainer/Control/Canvas
	
	FileHandler.page_changed.connect(_on_page_changed)

func _input(event):
	if event.is_action_pressed("ui_save"):
		_on_save_pressed()
	if event.is_action_pressed('ui_left'):
		FileHandler.back()
	if event.is_action_pressed('ui_right'):
		FileHandler.foward()
	if event.is_action_pressed('ui_redo'):
		mask.redo()
	if event.is_action_pressed('ui_undo'):
		mask.undo()
	if event.is_action_pressed('change_color'):
		black_check.button_pressed = not black_check.button_pressed
	if event.is_action_pressed('bucket'):
		bucket_check.button_pressed = not bucket_check.button_pressed
	#if event.is_action_pressed(''):
		#pass

func _on_download_finshed() -> void:
	OS.execute('unzip', ['/tmp/cleaner/mask.zip', '-d', '/tmp/cleaner/mask'])
	FileHandler.open()
	Notification.message("Download finished mask.zip")

func _on_ok_pressed():
	Client.url = $MarginContainer/VBoxContainer/HBoxContainer/URL.text
	Client.path = $MarginContainer/VBoxContainer/HBoxContainer/Path.text
	
	if DirAccess.dir_exists_absolute('/tmp/cleaner'):
			OS.execute('rm', ['/tmp/cleaner', '-rf'])
		
	DirAccess.make_dir_absolute('/tmp/cleaner')
	DirAccess.make_dir_absolute('/tmp/cleaner/raw')
	DirAccess.make_dir_absolute('/tmp/cleaner/mask')
	
	OS.execute('unzip', [Client.path, '-d', '/tmp/cleaner/raw'])
	Client.panel_cleaner()

func _on_redraw_pressed():
	if FileAccess.file_exists('/tmp/cleaner/mask.zip'):
		DirAccess.remove_absolute('/tmp/cleaner/mask.zip')
	
	Client.redraw()

func _on_back_pressed():
	FileHandler.back()

func _on_foward_pressed():
	FileHandler.foward()

func _on_page_changed(text) -> void:
	$MarginContainer/VBoxContainer/HBoxContainer2/HBoxContainer/Pages.text = text

func _on_save_pressed():
	if FileHandler.mask_images_path.is_empty():
		Notification.message("Você está na área de teste")
		return
	await RenderingServer.frame_post_draw
	var img : Image = sub_viewport_mask.get_texture().get_image()
	img.save_jpg(FileHandler.mask_images_path[FileHandler.current_page])
	Notification.message("Mask saved")
