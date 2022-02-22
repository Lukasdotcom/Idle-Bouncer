extends Control

func _ready() -> void:
	var file = File.new()
	file.open(Data.save_file, File.READ)
	$Export.text = Marshalls.utf8_to_base64(file.get_as_text())

func _on_Return_button_up() -> void:
	get_tree().change_scene("res://src/Loading.tscn")

func _on_Load_button_up() -> void:
	var file = File.new()
	file.open(Data.save_file, File.WRITE)
	file.store_string(Marshalls.base64_to_utf8($Import.text))
	file.close()
	_on_Return_button_up()
