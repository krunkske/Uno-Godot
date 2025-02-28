extends Control

var tween: Tween

func _ready() -> void:
	pass
	#if OS.get_name() == "Web":
		#$Panel/VBoxContainer/HBoxContainer3/ip_label.hide()
		#$Panel/VBoxContainer/HBoxContainer3/VSeparator.hide()
		#$"Panel/VBoxContainer/HBoxContainer2/ip-adress".hide()
		#$Panel/VBoxContainer/HBoxContainer2/VSeparator.hide()
		#$Panel/VBoxContainer/HBoxContainer4.hide()
		#$Panel/VBoxContainer/HBoxContainer/host.hide()
		#$Panel/VBoxContainer/HBoxContainer/VSeparator.hide()

## Creates the tween used for animating the bop in
func fade_out() -> void:
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SPRING)
	tween.tween_property($Panel, "scale", Vector2(0,0), 0.4)
	tween.tween_callback(self.hide)

func fade_in() -> void:
	self.show()
	if tween:
		tween.kill()
	tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_SPRING)
	tween.tween_property($Panel, "scale", Vector2(1,1), 0.4)

func _on_join_pressed() -> void:
	if $"Panel/VBoxContainer/HBoxContainer2/ip-adress".get_text():
		Lobby.playerName = $Panel/VBoxContainer/HBoxContainer2/name.get_text()
		if not Lobby.create_client($"Panel/VBoxContainer/HBoxContainer2/ip-adress".get_text()):
			printerr("Could not connect to server")
		else:
			fade_out()


func _on_port_toggled(toggled_on):
	$Panel/VBoxContainer/HBoxContainer4/port.set_editable(toggled_on)
	if not toggled_on:
		$Panel/VBoxContainer/HBoxContainer4/port.text = "8080"
