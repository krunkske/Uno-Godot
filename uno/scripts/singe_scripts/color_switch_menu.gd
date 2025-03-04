extends Control

var index := -1

func _ready() -> void:
	self.hide()

func choose_color(dex):
	self.show()
	index = dex


func _on_blue_pressed() -> void:
	Client.playCard(index, card_types.colors.BLUE)
	self.hide()


func _on_red_pressed() -> void:
	Client.playCard(index, card_types.colors.RED)
	self.hide()


func _on_yellow_pressed() -> void:
	Client.playCard(index, card_types.colors.YELLOW)
	self.hide()


func _on_green_pressed() -> void:
	Client.playCard(index, card_types.colors.GREEN)
	self.hide()
