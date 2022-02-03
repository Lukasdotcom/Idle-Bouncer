extends Node2D
signal update_game_interface # Signal for when to update the UI

var first
const save_file = "user://save.json"
var money = 0 setget change_money
var coins = 0 setget change_coins
var earnings = [0, 10, 50, 400]
var cost = [0, 100, 500, 4000]
var boxes = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var file = File.new()
	if file.file_exists(save_file):
		file.open(save_file, File.READ)
		var _data = parse_json(file.get_as_text())
		if _data["version"] == "v0.1.3":
			file.close()
			money = _data["money"]
			cost = _data["cost"]
			for x in _data["boxes"]:
				var _instance = load("res://src/box.tscn")
				_instance = _instance.instance()
				_instance.level = x[1]
				_instance.startAnimation = x[0]
				_instance.position = Vector2(512, 300)
				get_node("/root/Main/Game Field").call_deferred("add_child", _instance)

func change_money(value: int) -> void: # Changes the score
	money = value
	emit_signal("update_game_interface")

func change_coins(value: int) -> void: # Changes the score
	coins = value
	emit_signal("update_game_interface")

func reset_coins() -> void: # Resets the coins when space bar is pressed
	money += coins
	coins = 0
	emit_signal("update_game_interface")
	save()

func save() -> void: # Used to save the game
	var file = File.new()
	file.open(save_file, File.WRITE)
	var _save_data = to_json({
		"money" : money,
		"boxes" : boxes,
		"cost" : cost,
		"version" : "v0.1.3"
	})
	file.store_string(_save_data)
	file.close()
