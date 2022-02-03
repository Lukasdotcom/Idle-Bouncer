extends Node2D
onready var animation = $AnimationPlayer

var level: int = 1
var startAnimation: float = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation.seek(startAnimation)
	if not Data.first: # Makes sure to set the start time when the first one is created otherwise will add itself to the saving list
		Data.first = animation
	else:
		Data.boxes.append([animation.current_animation_position - Data.first.current_animation_position, level])
	Data.save() # Makes sure to save the game right away.
	var _sprite: Sprite = $Node2D/Sprite
	_sprite.set_modulate(Color.from_hsv((115+15*level)/360.0, 0.9, 1, 1))

func _on_hit(area: Area2D) -> void:
	Data.coins += Data.earnings[level]
