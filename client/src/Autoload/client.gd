extends Node

var url : String : set = set_url
var path : String : set = set_path

var download_mask : bool = false
var download_cleaned : bool = false

var client : SocketIOClient
var backendURL: String

signal download_finished

func panel_cleaner() -> void:
	if client:
		client.socketio_disconnect()
		client = null
		
	client = SocketIOClient.new(url + "/socket.io", {"token": "MY_AUTH_TOKEN"})
	
	client.on_engine_connected.connect(on_socket_ready)
	client.on_connect.connect(on_socket_connect)
	client.on_event.connect(on_socket_event)
	
	add_child(client)
	OS.execute('/home/xande/Applications/gdrive', ['files', 'upload', path])
	await get_tree().create_timer(10).timeout
	client.socketio_send("panel_cleaner", {'filename': path.get_file()})

func redraw() -> void:
	OS.execute('/home/xande/Languages/multi/cleaner/client/zip.sh', [])
	await get_tree().create_timer(10).timeout
	client.socketio_send("redraw")

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
	client.socketio_disconnect()

func on_socket_ready(_sid: String):
	client.socketio_connect()

func on_socket_connect(_payload: Variant, _name_space, error: bool):
	if error:
		push_error("Failed to connect to backend!")
	else:
		print("Socket connected")

func on_socket_event(event_name: String, _payload: Variant, _name_space):
	if event_name == 'download_mask':
		Notification.message("Downloading mask.zip")
		await get_tree().create_timer(10).timeout
		
		var output : Array = []
		OS.execute('/home/xande/Applications/gdrive', ['files', 'list'], output)
		var value : String = get_images_zip_id(output[0], 'mask')
		
		OS.execute('/home/xande/Applications/gdrive', ['files', 'download', value, '--destination', '/tmp/cleaner/'])
		
		emit_signal('download_finished')
	elif event_name == 'download_cleaned':
		Notification.message("Downloading result.zip")
		
		await get_tree().create_timer(10).timeout
		
		var output : Array = []
		OS.execute('/home/xande/Applications/gdrive', ['files', 'list'], output)
		var value : String = get_images_zip_id(output[0], 'result')
		
		OS.execute('/home/xande/Applications/gdrive', ['files', 'download', value, '--destination', path.get_base_dir()])
		
		Notification.message("result.zip downloaded")
	elif event_name == 'message':
		var data : Dictionary = JSON.parse_string(_payload)
		Notification.message(data.message)
