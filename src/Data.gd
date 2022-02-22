extends Node2D
signal update_game_interface # Signal for when to update the UI
signal ball_upgrades # Signal for when balls can be upgraded
signal golden_upgrades

var first
var first_animation
const save_file = "user://save.json"
var money = 0.0 setget change_money
var earnings = []
var cost = []
const additional_boxes = 24
var number_of_balls = 0
var boxes = []
var greatest_box = 0 # Stores the highest level box
var upgrades_amount = {"ball" : 1000, "golden" : 1000000} # Stores the amount of money needed to unlock upgrade
var upgrades = {"ball" : false, "golden" : false} # Used to check if balls can be upgraded
var balls = [[200.0, 10.0]]
var multiplier = 1
var speed_multiplier = 1
var duplicaters_duplicate = false
var box_limit = 10
var MPS = 0.0
var goldenChance = -0.003
var goldenStartChance = -0.003
var goldenIncrease = 0.000005
var goldenLength = 1
var goldenMagnitude = 1

func start() -> void: # Loads starting loader
	first = null
	first_animation = null
	cost = [0, 10, 50, 500, 4500, 60000, 590000]
	earnings = [0, 10, 50, 400, 2500, 14000, 85000]
	# Adds additional boxes
	var _previous_earnings = earnings[-1]
	var _previous_cost = cost[-1]
	for _x in range(additional_boxes):
		_previous_earnings *= 6.04
		_previous_cost *= 12.75
		earnings.append(floor(_previous_earnings))
		cost.append(floor(_previous_cost))
	var file = File.new()
	if file.file_exists(save_file): # Checks for a save file and then loads all the data from it
		file.open(save_file, File.READ)
		var _data = parse_json(file.get_as_text())
		if _data["version"] == "v0.5.0":
			for _x in range(15):
				_data["cost"].append(earnings.pop_back())
			_data["version"] = "v0.5.1"
		if _data["version"] == "v0.5.1":
			_data["MPS"] = 0
			_data["time"] = 100
			_data["version"] = "v0.5.2"
		if _data["version"] == "v0.5.2":
			_data["goldenStartChance"] = -0.003
			_data["goldenIncrease"] = 0.000005
			_data["goldenChance"] = -0.003
			_data["goldenLength"] = 1
			_data["goldenMagnitude"] = 1
			_data["upgrades"] = {"ball" : _data["ball_upgrades"], "golden" : false}
			_data["version"] = "v0.6.0"
		if _data["version"] == "v0.6.0":
			_data["performance"] = {"Simulate" : 100, "Show" : 100, "Ball" : 9.5}
			_data["version"] = "v0.6.1"
		if _data["version"] == "v0.6.1": # Loads the save
			goldenLength = _data["goldenLength"]
			goldenMagnitude = _data["goldenMagnitude"]
			goldenChance = _data["goldenChance"]
			goldenIncrease = _data["goldenIncrease"]
			goldenStartChance = _data["goldenStartChance"]
			balls = _data["balls"]
			money = _data["money"] + floor((OS.get_system_time_secs() - _data["time"]) * _data["MPS"] / 10.0)
			cost = _data["cost"]
			box_limit = _data["box_limit"]
			upgrades = _data["upgrades"]
			boxes = []
			greatest_box = 0
			for x in _data["boxes"]: # Loads every box available
				var _instance = load("res://src/box.tscn")
				_instance = _instance.instance()
				_instance.level = x[1]
				_instance.startAnimation = x[0]
				_instance.position = Vector2(512, 300)
				if greatest_box < x[1]:
					greatest_box = x[1]
				get_node("/root/Main/Game Field").call_deferred("add_child", _instance)
			# Loads performance settings
			for x in _data["performance"]:
				get_node("/root/Main/TabContainer/Performance/" + x).value = _data["performance"][x]
		else: # Runs info for when no save is found
			goldenLength = 1
			goldenMagnitude = 1
			upgrades = {"ball" : false, "golden" : false}
			goldenChance = -0.003
			goldenIncrease = 0.000005
			goldenStartChance = -0.003
			MPS = 0
			balls = [[200.0, 10.0]]
			money = 0.0
			box_limit = 10
			for x in upgrades:
				upgrades[x] = false
			boxes = []
			greatest_box = 1
			first = null
			first_animation = null
			var _instance = load("res://src/box.tscn")
			_instance = _instance.instance()
			_instance.level = 1
			_instance.startAnimation = 0
			_instance.position = Vector2(512, 300)
			get_node("/root/Main/Game Field").call_deferred("add_child", _instance)
		file.close()
		var _level = 1
		for x in balls:
			spawn_ball(_level)
			_level += 1

func change_money(value: float) -> void: # Changes the score
	money = value
	emit_signal("update_game_interface")
	for x in upgrades:
		if not upgrades[x] and value > upgrades_amount[x]: # Checks if ball's can be purchased.
			upgrades[x] = true
			emit_signal(x+"_upgrades")

func save() -> void: # Used to save the game
	var file = File.new()
	file.open(save_file, File.WRITE)
	var _save_data = to_json({
		"money" : floor(money),
		"boxes" : boxes,
		"box_limit" : box_limit,
		"cost" : cost,
		"upgrades" : upgrades,
		"balls" : balls,
		"MPS" : MPS,
		"time" : OS.get_system_time_secs(),
		"goldenStartChance" : goldenStartChance,
		"goldenIncrease" : goldenIncrease,
		"goldenChance" : goldenChance,
		"goldenLength" : goldenLength,
		"goldenMagnitude" : goldenMagnitude,
		"performance" : {"Simulate" : get_node("/root/Main/TabContainer/Performance/Simulate").value, "Show" : get_node("/root/Main/TabContainer/Performance/Show").value, "Ball" : get_node("/root/Main/TabContainer/Performance/Ball").value},
		"version" : "v0.6.1"
	})
	file.store_string(_save_data)
	file.close()

func beautify(val: float) -> String: # Will make a big number easier to read
	var shortcut = ["", "K", "M", "B", "T", "Q", "Qu", "S", "Sp", "O", "N", "D", "U", "Crazy", "Maniac", "When will you stop playing", "Where is your life", "Do you even have a life", "You dont have a life", "I'm Done"]
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
		"version" : "null"
	})
	file.store_string(_save_data)
	file.close()
	get_tree().change_scene("res://src/Main.tscn")

func spawn_ball(level: int) -> void: # Used to spawn a new ball
	var _instance = load("res://src/ball.tscn")
	_instance = _instance.instance()
	_instance.level = level
	get_node("/root/Main/Game Field").call_deferred("add_child", _instance)

func box_number(level: int = 0) -> int: # Returns the number of boxes that are at that level. You can also put in 0 to get the number of boxes
	if level == 0:
		return len(boxes)
	var _count = 0
	for x in boxes:
		if x[1] == level:
			_count += 1
	return _count

func box_number_cost() -> float: # Returns the current cost for a new box
	return floor(pow(10, (box_limit / 5) + 1)) 
