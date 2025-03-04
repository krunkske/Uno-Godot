extends Control

var screen_size : Vector2
var tween : Tween
var tween2 : Tween

@export var username: String :
	get:
		return username
	set(value):
		username = value
		$VBoxContainer/username.text = value

func _ready() -> void:
	screen_size = get_viewport().get_visible_rect().size
	match name:
		"player_icon1":
			$VBoxContainer/username.text = "You"
			global_position = Vector2(screen_size.x/2, screen_size.y - 225)
		"player_icon2":
			global_position = Vector2(225, screen_size.y/2)
		"player_icon3":
			global_position = Vector2(screen_size.x/2, 225)
		"player_icon4":
			global_position = Vector2(screen_size.x - 225, screen_size.y/2)


func bop_in():
	if tween:
		tween.kill()
	if tween2:
		tween2.kill()
	
	tween = get_tree().create_tween()
	tween2 = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween2.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "scale", Vector2(0.6, 0.6), 0.5)
	tween2.tween_property($VBoxContainer/icon, "self_modulate", Color(1.0, 1.0, 1.0, 1.0), 0.5)


func bop_out():
	if tween:
		tween.kill()
	if tween2:
		tween2.kill()
	
	tween = get_tree().create_tween()
	tween2 = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween2.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "scale", Vector2(0.5,0.5), 0.5)
	tween2.tween_property($VBoxContainer/icon, "self_modulate", Color(1.0, 1.0, 1.0, 0.6), 0.5)


func fade_out():
	if $VBoxContainer/username.text == "Connecting...":
		if tween:
			tween.kill()
		tween = get_tree().create_tween()
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(self, "scale", Vector2(0,0), 0.75)
	else :
		bop_out()
