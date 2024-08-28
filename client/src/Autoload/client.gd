extends Node

var thread : Thread

var url : String : set = set_url
var path : String : set = set_path

var client : SocketIOClient
var backendURL: String
var logger : TextEdit
var timer : Timer

signal download_finished

func _ready():
	thread = Thread.new()

func panel_cleaner() -> void:
	if client:
		client.socketio_disconnect()
		client = null
	
	client = SocketIOClient.new(url + "/socket.io", {"token": "MY_AUTH_TOKEN"})
	
	client.on_engine_connected.connect(on_socket_ready)
	client.on_connect.connect(on_socket_connect)
	client.on_event.connect(on_socket_event)
	
	add_child(client)
	# delete raw.zip in gdrive
	if thread.is_started():
		thread.wait_to_finish()
	
	thread.start(upload_gdrive.bind(path, logger, func(): 
		await get_tree().create_timer(50).timeout
		client.socketio_send("panel_cleaner", {})
	))

func redraw() -> void:
	OS.execute('/home/xande/Languages/multi/cleaner/client/zip.sh', [])
	if thread.is_started():
		thread.wait_to_finish()
	
	thread.start(upload_gdrive.bind('/tmp/cleaner/mask.zip', logger, func():
		await get_tree().create_timer(50).timeout
		client.socketio_send("redraw")
	))

func get_images_zip_id(data: String, filename : String) -> String:
	var pattern = r"(\S+)\s+{filename}\.zip".format({'filename': filename})
	var regex = RegEx.new()
	regex.compile(pattern)
	
	var match = regex.search(data)
	if match:
		return match.get_string(0).split(' ')[0]
	else:
		return "images.zip não encontrado."

func set_url(value : String) -> void:
	url = value

func set_path(value : String) -> void:
	path = value

func _exit_tree():
	client.socketio_disconnet()
	thread.wait_to_finish()

func on_socket_ready(_sid: String):
	client.socketio_connect()

func on_socket_connect(_payload: Variant, _name_space, error: bool):
	if error:
		logger.text += '\nFailed to connect to backend!'
		logger.get_v_scroll_bar().value += 100
	else:
		logger.text += '\nSocket connected'
		logger.get_v_scroll_bar().value += 100
		timer.start(40)

func upload_gdrive(_path : String, _logger : TextEdit, callback : Callable) -> void:
	var output : Array = []
	OS.execute('/home/xande/Applications/gdrive', ['files', 'upload', _path], output)
	_logger.set_deferred('text', _logger.text + '\n' + output[0])
	callback.call_deferred()

func download_gdrive(id : String, destination : String, _logger : TextEdit, callback : Callable) -> void:
	var output : Array = []
	OS.execute('/home/xande/Applications/gdrive', ['files', 'download', id, '--destination', destination], output)
	_logger.set_deferred('text', _logger.text + '\n' + output[0])
	callback.call_deferred()

func on_socket_event(event_name: String, _payload: Variant, _name_space):
	if event_name == 'download_mask':
		Notification.message("Downloading mask.zip")
		logger.text += '\nDownloading mask.zip'
		logger.get_v_scroll_bar().value += 100
		print('Downloading mask.zip')
		await get_tree().create_timer(20).timeout
		
		var output : Array = []
		OS.execute('/home/xande/Applications/gdrive', ['files', 'list'], output)
		var value : String = get_images_zip_id(output[0], 'mask')
		
		if thread.is_started():
			thread.wait_to_finish()
		thread.start(download_gdrive.bind(value, '/tmp/cleaner/', logger, func(): 
			OS.execute('/home/xande/Applications/gdrive', ['files', 'delete', value])
			emit_signal('download_finished')
		))
	elif event_name == 'download_cleaned':
		print("Downloading result.zip")
		Notification.message("Downloading result.zip")
		logger.text += '\nDownloading result.zip'
		logger.get_v_scroll_bar().value += 100
		
		await get_tree().create_timer(20).timeout
		
		var output : Array = []
		OS.execute('/home/xande/Applications/gdrive', ['files', 'list'], output)
		var value : String = get_images_zip_id(output[0], 'result')
		
		if thread.is_started():
			thread.wait_to_finish()
		
		thread.start(download_gdrive.bind(value, path.get_base_dir(), logger, func(): 
			Notification.message("result.zip downloaded")
			logger.text += '\nresult.zip downloaded'
			logger.get_v_scroll_bar().value += 100
		))
	
	elif event_name == 'ping':
		logger.text += 'ping'
		logger.get_v_scroll_bar().value += 100
	elif event_name == 'log':
		pass
