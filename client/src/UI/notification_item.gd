extends Panel

func message(text: String) -> void:
	$MarginContainer/Label.text = text
	get_tree().create_timer(5).timeout.connect(queue_free)
