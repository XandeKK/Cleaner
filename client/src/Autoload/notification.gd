extends Node

var notification_body : VBoxContainer
var notification_item : PackedScene = load("res://src/UI/notification_item.tscn")

func message(text: String) -> void:
	var _notification : Panel = notification_item.instantiate()
	notification_body.add_child(_notification)
	_notification.message(text)
