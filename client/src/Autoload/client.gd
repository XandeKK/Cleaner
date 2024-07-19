extends Node

var url : String : set = set_url
var path : String : set = set_path
var request : HTTPRequest

var download_mask : bool = false
var download_cleaned : bool = false

var client : SocketIOClient
var backendURL: String

signal download_finished

func _ready():
	request = HTTPRequest.new()
	request.connect("request_completed", _request_callback)
	add_child(request)

func _request_callback(_result, _response_code, _headers, _body) -> void:
	if download_mask:
		print('mask.zip downloaded')
		emit_signal('download_finished')
		download_mask = false
		Notification.message("mask.zip downloaded")
	elif download_cleaned:
		print('result.zip downloaded')
		Notification.message("result.zip downloaded")
		download_cleaned = false

func send_images() -> void:
	if client:
		client.socketio_disconnect()
		client = null
		
	client = SocketIOClient.new(url + "/socket.io", {"token": "MY_AUTH_TOKEN"})
	
	client.on_engine_connected.connect(on_socket_ready)
	client.on_connect.connect(on_socket_connect)
	client.on_event.connect(on_socket_event)
	
	add_child(client)
	
	var file : FileAccess = FileAccess.open(path, FileAccess.READ)
	var file_content = file.get_buffer(file.get_length())
	file.close()

	var body = PackedByteArray()
	body.append_array("\r\n--WebKitFormBoundaryePkpFF7tjBAqx29L\r\n".to_utf8_buffer())
	body.append_array("Content-Disposition: form-data; name=\"file\"; filename=\"raw.zip\"\r\n".to_utf8_buffer())
	body.append_array("Content-Type: application/zip\r\n\r\n".to_utf8_buffer())
	body.append_array(file_content)
	body.append_array("\r\n--WebKitFormBoundaryePkpFF7tjBAqx29L--\r\n".to_utf8_buffer())
	
	var headers = [
		"Content-Type: multipart/form-data;boundary=\"WebKitFormBoundaryePkpFF7tjBAqx29L\""
	]
	
	var error = request.request_raw(url + "/images", headers, HTTPClient.METHOD_POST, body)
	Notification.message("send images")
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func redraw() -> void:
	var file : FileAccess = FileAccess.open('/tmp/cleaner/mask.zip', FileAccess.READ)
	var file_content = file.get_buffer(file.get_length())
	file.close()

	var body = PackedByteArray()
	body.append_array("\r\n--WebKitFormBoundaryePkpFF7tjBAqx29L\r\n".to_utf8_buffer())
	body.append_array("Content-Disposition: form-data; name=\"file\"; filename=\"mask.zip\"\r\n".to_utf8_buffer())
	body.append_array("Content-Type: application/zip\r\n\r\n".to_utf8_buffer())
	body.append_array(file_content)
	body.append_array("\r\n--WebKitFormBoundaryePkpFF7tjBAqx29L--\r\n".to_utf8_buffer())
	
	var headers = [
		"Content-Type: multipart/form-data;boundary=\"WebKitFormBoundaryePkpFF7tjBAqx29L\""
	]
	
	var error = request.request_raw(url + "/redraw", headers, HTTPClient.METHOD_POST, body)
	Notification.message("Redraw")
	if error != OK:
		push_error("An error occurred in the HTTP request.")

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
		request.download_file = '/tmp/cleaner/mask.zip'
		request.request(url + "/file?path=mask.zip")
		Notification.message("Downloading mask.zip")
		download_mask = true
	elif event_name == 'download_cleaned':
		request.download_file = path.get_base_dir().path_join('cleaned.zip')
		request.request(url + "/file?path=result.zip")
		Notification.message("Downloading result.zip")
		download_cleaned = true
