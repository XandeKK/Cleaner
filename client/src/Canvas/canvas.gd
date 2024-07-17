extends SubViewportContainer

@onready var raw_image : TextureRect = $SubViewport/BottomCanvas/SubViewport/Raw
@onready var mask_image : Mask = $SubViewport/BottomCanvas/SubViewport/Mask
@onready var camera : Camera2D = $SubViewport/Camera2D
@onready var bottom_canvas : SubViewportContainer = $SubViewport/BottomCanvas

func load_raw_image(texture : ImageTexture) -> void:
	raw_image.texture = texture
	raw_image.size = texture.get_size()

func load_mask_image(texture : ImageTexture) -> void:
	mask_image.image_texture = texture
	mask_image.size = texture.get_size()
	bottom_canvas.size = texture.get_size()
	
	camera.position = Vector2(texture.get_size().x / 2, get_viewport().size.y - 50)
