extends Node

var url : String : set = set_url
var path : String : set = set_path
var request : HTTPRequest

var upload_images : bool = false
var download : bool = false
var upload_redraw : bool = false

signal download_finished

func _ready():
	request = HTTPRequest.new()
	request.connect("request_completed", _request_callback)
	add_child(request)

func _request_callback(_result, _response_code, _headers, body) -> void:
	if upload_images:
		request.request(url + "/file?path=mask.zip")
		upload_images = false
		download = true
	elif download:
		var file : FileAccess = FileAccess.open('/tmp/cleaner/mask.zip', FileAccess.WRITE)
		file.store_buffer(body)
		file.close()
		download = false
		emit_signal('download_finished')
	elif upload_redraw:
		var file : FileAccess = FileAccess.open(path.get_base_dir().path_join('cleaned.zip'), FileAccess.WRITE)
		file.store_buffer(body)
		file.close()
		upload_redraw = false

func send_images() -> void:
	var file : FileAccess = FileAccess.open(path, FileAccess.READ)
	var file_content = file.get_buffer(file.get_length())
	upload_images = true

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
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func redraw() -> void:
	var file : FileAccess = FileAccess.open('/tmp/cleaner/mask.zip', FileAccess.READ)
	var file_content = file.get_buffer(file.get_length())
	upload_redraw = true

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
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func set_url(value : String) -> void:
	url = value

func set_path(value : String) -> void:
	path = value
