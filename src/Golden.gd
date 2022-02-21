extends Node2D
var _rng = RandomNumberGenerator.new()
onready var label = $Label
onready var timeText = $time
onready var second = $Second
var time_left = 0
var cookieExists = false

func _ready() -> void:
	_rng.randomize()
	self.scale = Vector2(0.6, 0.6)
	_ready_cookie()

func _ready_cookie() -> void: # Used to get the cookie ready
	cookieExists = false
	Data.multiplier = 1
	Data.speed_multiplier = 1
	Data.duplicaters_duplicate = false
	self.hide()
	label.hide()
	timeText.hide()
	$Button.show()
	Data.goldenChance = Data.goldenStartChance
	second.start()

func _on_Button_button_up() -> void: # Starts the golden effect
	$Button.hide()
	timeText.show()
	var _choice = _rng.randi_range(0, 3)
	if _choice == 0: # A x7 multiplier for 77 seconds
		time_left = 77
		label.text = "x7 multiplier"
		Data.multiplier = 7
	elif _choice == 1: # A x77 multiplier for 7 seconds 
		time_left = 7
		label.text = "x77 multiplier"
		Data.multiplier = 77
	elif _choice == 2: # Will allow for duplicated balls to duplicate for 60 seconds.
		time_left = 30
		label.text = "Duplicating Duplicators"
		Data.duplicaters_duplicate = true
	else:
		time_left = 33
		label.text = "x3 Speed"
		Data.speed_multiplier = 3
	label.show()
	_update_circle()
	cookieExists = true
	second.start()


func _on_Second_timeout() -> void:
	if cookieExists: # Checks if the cookie exists or not
		time_left -= 1
		if time_left > 0:
			_update_circle()
		else:
			_ready_cookie()
	else:
		if _rng.randf() < Data.goldenChance:
			self.position = Vector2(_rng.randf() * 824 + 100, _rng.randf() * 400 + 100)
			self.show()
			second.stop()
		Data.goldenChance += Data.goldenIncrease

func _update_circle() -> void:
	timeText.text = str(time_left)
