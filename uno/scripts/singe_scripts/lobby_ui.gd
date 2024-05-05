extends Control

var tween

# Called when the node enters the scene tree for the first time.
func _ready():
	if OS.get_name() == "Web":
		$Panel/VBoxContainer/HBoxContainer3/ip_label.hide()
		$Panel/VBoxContainer/HBoxContainer3/VSeparator.hide()
		$"Panel/VBoxContainer/HBoxContainer2/ip-adress".hide()
		$Panel/VBoxContainer/HBoxContainer2/VSeparator.hide()
		$Panel/VBoxContainer/HBoxContainer4.hide()
		$Panel/VBoxContainer/HBoxContainer/host.hide()
		$Panel/VBoxContainer/HBoxContainer/VSeparator.hide()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func create_tweens():
	tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SPRING)
	tween.tween_property($Panel, "scale", Vector2(0,0), 0.4)
	tween.tween_callback(self.hide)

func _on_join_pressed():
	if $"Panel/VBoxContainer/HBoxContainer2/ip-adress".get_text():
		Lobby.playerName = $Panel/VBoxContainer/HBoxContainer2/name.get_text()
		if not Lobby.create_client($"Panel/VBoxContainer/HBoxContainer2/ip-adress".get_text()):
			Aload.top_gui.get_node("Label").set_text("Could not connect to server.")
		else:
			create_tweens()


func _on_port_toggled(toggled_on):
	$Panel/VBoxContainer/HBoxContainer4/port.set_editable(toggled_on)
	if not toggled_on:
		$Panel/VBoxContainer/HBoxContainer4/port.text = "8080"
