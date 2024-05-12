extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/start.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	$VBoxContainer/start.hide()
	if multiplayer.is_server():
		Lobby.is_authorized()
	else:
		Lobby.is_authorized.rpc_id(1)
