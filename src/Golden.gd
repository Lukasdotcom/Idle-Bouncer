extends Node2D
var _rng = RandomNumberGenerator.new()
onready var timer = $Timer
onready var label = $Label
onready var timeText = $time
onready var second = $Second
var time_left = 0

func _ready() -> void:
	_rng.randomize()
	self.scale = Vector2(0.6, 0.6)
	_ready_cookie()

func _random_spawn_time() -> float: # Will return a random amount of time in which the golden will spawn
	var _x = _rng.randf()
	return 300 + 600 * _x

func _on_Timer_timeout() -> void: # Shows a golden circle somewhere random
	self.position = Vector2(_rng.randf() * 824 + 100, _rng.randf() * 400 + 100)
	self.show()

func _ready_cookie() -> void: # Used to get the cookie ready
	Data.multiplier = 1
	Data.duplicaters_duplicate = false
	self.hide()
	label.hide()
	timeText.hide()
	timer.wait_time = _random_spawn_time()
	timer.start()

func _on_Button_button_up() -> void: # Starts the golden effect
	timeText.show()
	var _choice = _rng.randi_range(0, 2)
	if _choice == 0: # A x7 multiplier for 77 seconds
		time_left = 77
		label.text = "x7 multiplier"
		Data.multiplier = 7
	elif _choice == 1: # A x77 multiplier for 7 seconds 
		time_left = 7
		label.text = "x77 multiplier"
		Data.multiplier = 77
	else: # Will allow for duplicated balls to duplicate for 60 seconds.
		time_left = 60
		label.text = "Duplicating Duplicators"
		Data.duplicaters_duplicate = true
	label.show()
	_update_circle()
	second.start()


func _on_Second_timeout() -> void:
	time_left -= 1
	if time_left > 0:
		second.start()
		_update_circle()
	else:
		_ready_cookie()

func _update_circle() -> void:
	timeText.text = str(time_left)
