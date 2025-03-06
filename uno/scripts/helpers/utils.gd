extends Node

func printLn(text: String) -> void:
	if multiplayer.is_server():
		print("SERVER: " + text)
	else:
		var id := multiplayer.get_unique_id()
		print("CLIENT %s: %s" %[id, text])

func printerrLn(text: String) -> void:
	if multiplayer.is_server():
		printerr("SERVER: %s" %text)
	else:
		var id := multiplayer.get_unique_id()
		printerr("CLIENT %s: %s" %[id, text])
