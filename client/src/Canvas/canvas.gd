extends SubViewportContainer

@onready var raw_image : TextureRect = $SubViewport/BottomCanvas/SubViewport/Raw
@onready var canvas_mask_image : SubViewportContainer = $SubViewport/BottomCanvas/SubViewport/SubViewportContainer
@onready var mask_image : Mask = $SubViewport/BottomCanvas/SubViewport/SubViewportContainer/SubViewport/Mask
@onready var camera : Camera2D = $SubViewport/Camera2D
@onready var bottom_canvas : SubViewportContainer = $SubViewport/BottomCanvas

@export var opacity : HSlider

func _ready():
	var img : Image = Image.create(800, 1000, true, Image.FORMAT_RGBA8)
	img.fill(Color.BLACK)
	var img_tex : ImageTexture = ImageTexture.create_from_image(img)
	load_mask_image(img_tex)

func load_raw_image(texture : ImageTexture) -> void:
	raw_image.texture = texture
	raw_image.size = texture.get_size()

func load_mask_image(texture : ImageTexture) -> void:
	mask_image.history_undo.clear()
	mask_image.history_redo.clear()
	mask_image.image_texture = texture
	mask_image.size = texture.get_size()
	bottom_canvas.size = texture.get_size()
	canvas_mask_image.size = texture.get_size()
	canvas_mask_image.modulate = Color(Color.WHITE, opacity.value)
	
	camera.position = Vector2(texture.get_size().x / 2, get_viewport().size.y - 50)

func _on_opacity_value_changed(value : float) -> void:
	canvas_mask_image.modulate = Color(Color.WHITE, value)
