extends Node2D
signal update_game_interface

var money = 0 setget change_money
var coins = 0 setget change_coins
var earnings = [0, 10, 50, 400]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func change_money(value: int) -> void: # Changes the score
	money = value
	emit_signal("update_game_interface")

func change_coins(value: int) -> void: # Changes the score
	coins = value
	emit_signal("update_game_interface")

func reset_coins() -> void:
	money += coins
	coins = 0
	emit_signal("update_game_interface")
