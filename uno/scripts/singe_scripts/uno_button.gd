extends Control

var tween
var active = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func start_bobbing():
	if active:
		if tween:
			tween.kill()
		print("started")
		
		tween = get_tree().create_tween()
		tween.set_trans(Tween.TRANS_SINE)
		tween.tween_property(self, "scale", Vector2(1.1, 1.1), 1.0)
		tween.tween_property(self, "scale", Vector2(1, 1), 1.0)
		tween.tween_callback(start_bobbing)


func _on_button_pressed() -> void:
	Aload.client_node.pressed_uno()
	active = false


func _on_timer_timeout() -> void:
	Aload.server_node.missed_uno.rpc_id(1)
	active = false
