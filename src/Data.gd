extends Node2D
signal update_game_interface # Signal for when to update the UI

var first
const save_file = "user://save.json"
var money = 0.0 setget change_money
var coins = 0.0 setget change_coins
var earnings = [0, 10, 50, 400, 2500, 14000, 85000]
var cost = [0, 100, 500, 5000, 45000, 600000, 5900000]
const additional_boxes = 15
var boxes = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Adds additional boxes
	var _previous_earnings = earnings[-1]
	var _previous_cost = cost[-1]
	for x in range(additional_boxes):
		_previous_earnings *= 6.04
		_previous_cost *= 12.75
		earnings.append(_previous_earnings)
		cost.append(_previous_cost)
	var file = File.new()
	if file.file_exists(save_file): # Checks for a save file and then loads all the data from it
		file.open(save_file, File.READ)
		var _data = parse_json(file.get_as_text())
		if _data["version"] == "v0.1.3": # updates save to v0.1.4
			for x in range(7, 21):
				_data["cost"][x] = cost[x]
				_data["version"] = "v0.1.4"
		if _data["version"] == "v0.1.4": # Loads the save
			file.close()
			money = _data["money"]
			cost = _data["cost"]
			for x in _data["boxes"]: # Loads every box available
				var _instance = load("res://src/box.tscn")
				_instance = _instance.instance()
				_instance.level = x[1]
				_instance.startAnimation = x[0]
				_instance.position = Vector2(512, 300)
				get_node("/root/Main/Game Field").call_deferred("add_child", _instance)

func change_money(value: float) -> void: # Changes the score
	money = value
	emit_signal("update_game_interface")

func change_coins(value: float) -> void: # Changes the score
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
		"version" : "v0.1.4"
	})
	file.store_string(_save_data)
	file.close()

func beautify(val: float) -> String: # Will make a big number easier to read
	var shortcut = ["", "thousand", "million", "billion", "trillion", "quadrillion", "quintillion", "sextillion", "septillion", "octillion", "nonillion", "decillion"]
	var length = beautifyHelper(val, -1)
	return "%s %s" % [floor(val / (pow(10,(length - (length % 3) - 3)))) / 1000, shortcut[floor(length / 3)]]

func beautifyHelper(val: float, count: int) -> int: # A helper function for beautify
	if(val or count == -1):
		return beautifyHelper(floor(val / 10), count+1)
	return count

func reset() -> void: # Used to reset the game
	var file = File.new()
	file.open(save_file, File.WRITE)
	var _save_data = to_json({
		"version" : "empty"
	})
	file.store_string(_save_data)
	file.close()
