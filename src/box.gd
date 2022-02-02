extends Node2D


var level: int = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var _sprite: Sprite = $Node2D/Sprite
	_sprite.set_modulate(Color.from_hsv((100+30*level)/360.0, 0.9, 1, 1))



func _on_hit(area: Area2D) -> void:
	Data.coins += Data.earnings[level]
