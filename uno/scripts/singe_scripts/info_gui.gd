extends Control

func _ready() -> void:
	$VBoxContainer/start.show()


func _on_start_pressed() -> void:
	$VBoxContainer/start.hide()
	Lobby.is_authorized.rpc_id(1)
