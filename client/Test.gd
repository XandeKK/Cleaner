extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_timer_timeout():
	var scroll : VScrollBar = $TextEdit.get_v_scroll_bar()
	$TextEdit.text += str(scroll.value) + "Hello, world!\n"
	scroll.value += 10
