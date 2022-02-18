extends Control



# Checks if a save exists and if it does allows a way to reset otherwise will load the game right away.
func _ready() -> void:
	var file = File.new()
	if file.file_exists(Data.save_file):
		file.open(Data.save_file, File.READ)
		var _data = parse_json(file.get_as_text())
		if _data["version"] in ["v0.5.0", "v0.5.1"]:
			$Save.visible = true
			$Timer.start()
			
		else:
			get_tree().change_scene("res://src/Main.tscn")
	else:
		get_tree().change_scene("res://src/Main.tscn")

func _on_Timer_timeout() -> void: # Waits to start the game
	get_tree().change_scene("res://src/Main.tscn")

func _on_Button_button_up() -> void: # Resets the game
	Data.reset()
