extends Node2D
signal update_game_interface # Signal for when to update the UI
signal ball_upgrades # Signal for when balls can be upgraded

var first
const save_file = "user://save.json"
var money = 099999999999999909999999.0 setget change_money
var earnings = [0, 10, 50, 400, 2500, 14000, 85000]
var cost = [0, 10, 50, 500, 4500, 60000, 590000]
const additional_boxes = 9
var number_of_balls = 0
var boxes = []
var ball_upgrades = false # Used to check if balls can be upgraded
var balls = [[200.0, 10.0]]
var multiplier = 1
var speed_multiplier = 1
var duplicaters_duplicate = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Adds additional boxes
	var _previous_earnings = earnings[-1]
	var _previous_cost = cost[-1]
	for x in range(additional_boxes):
		_previous_earnings *= 6.04
		_previous_cost *= 12.75
		earnings.append(floor(_previous_earnings))
		cost.append(floor(_previous_cost))
	var file = File.new()
	if file.file_exists(save_file): # Checks for a save file and then loads all the data from it
		file.open(save_file, File.READ)
		var _data = parse_json(file.get_as_text())
		if _data["version"] == "v0.1.3": # updates save to v0.1.4
			for x in range(7, 21):
				_data["cost"][x] = cost[x]
			_data["version"] = "v0.1.4"
		if _data["version"] == "v0.1.4": # updates save to v0.1.4
			# Removes the last 6 elements because those were removed
			_data["cost"].pop_back()
			_data["cost"].pop_back()
			_data["cost"].pop_back()
			_data["cost"].pop_back()
			_data["cost"].pop_back()
			_data["cost"].pop_back()
			_data["version"] = "v0.1.5"
		if _data["version"] == "v0.1.5":
			for x in range(15):
				_data["cost"][x] = floor(_data["cost"][x] / 10)
			_data["version"] = "v0.3.0"
		if _data["version"] == "v0.3.0": # Introduces the save for balls
			_data["balls"] = balls
			_data["ball_upgrades"] = false
			_data["version"] = "v0.4.0"
		if _data["version"] == "v0.4.0": # Loads the save
			file.close()
			balls = _data["balls"]
			money = _data["money"]
			cost = _data["cost"]
			ball_upgrades = _data["ball_upgrades"]
			for x in _data["boxes"]: # Loads every box available
				var _instance = load("res://src/box.tscn")
				_instance = _instance.instance()
				_instance.level = x[1]
				_instance.startAnimation = x[0]
				_instance.position = Vector2(512, 300)
				get_node("/root/Main/Game Field").call_deferred("add_child", _instance)
		var _level = 1
		for x in balls:
			spawn_ball(_level)
			_level += 1

func change_money(value: float) -> void: # Changes the score
	money = value
	emit_signal("update_game_interface")
	if not ball_upgrades and value > 1000: # Checks if ball's can be purchased.
		Data.save()
		ball_upgrades = true
		emit_signal("ball_upgrades")

func save() -> void: # Used to save the game
	var file = File.new()
	file.open(save_file, File.WRITE)
	var _save_data = to_json({
		"money" : floor(money),
		"boxes" : boxes,
		"cost" : cost,
		"ball_upgrades" : ball_upgrades,
		"balls" : balls,
		"version" : "v0.4.0"
	})
	file.store_string(_save_data)
	file.close()

func beautify(val: float) -> String: # Will make a big number easier to read
	var shortcut = ["", "K", "M", "B", "T", "Q", "Qu", "S", "Sp", "O", "N", "D"]
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

func spawn_ball(level: int) -> void: # Used to spawn a new ball
	var _instance = load("res://src/ball.tscn")
	_instance = _instance.instance()
	_instance.level = level
	get_node("/root/Main/Game Field").call_deferred("add_child", _instance)
