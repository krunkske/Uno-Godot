extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func win_or_lose(username, won):
	self.set_visible(true)
	if won:
		$VBoxContainer/Label.text = "You won!"
	else:
		$VBoxContainer/Label.text = str(username) + " won!"


func _on_main_menu_pressed() -> void:
	self.set_visible(false)
	Aload.reset()
