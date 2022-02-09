extends Node2D
onready var _vBoxContainer: VBoxContainer = $ScrollContainer/VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_interface()
	Data.connect("update_game_interface", self, "update_interface")
	Data.connect("ball_upgrades", self, "ball_upgrades")
	var _purchase = load("res://src/purchase.tscn")
	var _instance
	for x in range(len(Data.cost)):
		if x == 0:
			continue
		_instance = _purchase.instance()
		_instance.level = x
		_vBoxContainer.call_deferred("add_child", _instance)
	if Data.ball_upgrades: # Checks if ball upgrades is already on
		ball_upgrades()


func update_interface() -> void:
	get_node("/root/Main/Money").text = "Money: %s" % Data.beautify(Data.money)

func _on_Reset_button_up() -> void: # Used to reset the game
	Data.reset()

func ball_upgrades() -> void: # Used to enable the ball upgrades
	var scroll_container = $Ball/VBoxContainer
	$Ball.show()
	$ScrollContainer.rect_size.y = 400
	var _ball = load("res://src/purchase.tscn")
	for x in range(1, 10):
		var _instance = _ball.instance()
		_instance.level = x
		_instance.ball = true
		scroll_container.call_deferred("add_child", _instance)

# Saves the game every 30 seconds and every time the save button is pressed
func _on_Save_timeout() -> void:
	Data.save()

func _on_Save_Button_button_up() -> void:
	Data.save()
