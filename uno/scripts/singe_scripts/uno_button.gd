extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	Aload.client_node.pressed_uno()


func _on_timer_timeout() -> void:
	Aload.server_node.missed_uno.rpc_id(1)
