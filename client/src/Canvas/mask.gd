extends TextureRect
class_name Mask

@onready var brush : Brush = $Brush

var image : Image
var image_texture : ImageTexture : set = set_image_texture

func set_image_texture(value : ImageTexture) -> void:
	image_texture = value
	texture = value
	image = value.get_image()

func _on_opacity_value_changed(value):
	modulate = Color(Color.WHITE, value)
