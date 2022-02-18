extends Node2D
onready var animation = $AnimationPlayer

var level: int = 1
var startAnimation: float = 0
var id = [0, 1]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Data.cost.size() <= level or Data.earnings.size() <= level: # Makes sure that this is not an invalid level
		self.queue_free()
	else:
		animation.seek(startAnimation)
		if typeof(Data.first) != 17 : # Makes sure to set the start time when the first one is created and will add itself to the saving list
			Data.first = animation
			Data.first_animation = startAnimation
		id = [animation.current_animation_position - Data.first.current_animation_position + Data.first_animation, level]
		Data.boxes.append(id)
		Data.money += 0
		var _sprite: Sprite = $Node2D/Sprite
		if level > 15:
			_sprite.scale = Vector2(0.1, 0.1)
			_sprite.set_modulate(Color.from_hsv((120+20*(level-15))/360.0, 0.9, 1, 1))
		else:
			_sprite.set_modulate(Color.from_hsv((120+20*level)/360.0, 0.9, 1, 1))

func _on_hit(area: Area2D) -> void:
	var _earnings = Data.earnings[level] * Data.multiplier
	Data.money += _earnings
	get_node("../../MPS Calculator").earnings(_earnings)

func delete() -> void:
	if Data.boxes.find(id) != -1:
		Data.boxes.remove(Data.boxes.find(id))
	else:
		print("Error with cleaning up after box deletion")
	if Data.first == animation: # Checks if this was the first box
		Data.first = null
		for x in get_node("/root/Main/Game Field").get_children():
			if "box" in x.get_name() and  x != self:
				Data.first = x.animation
				Data.first_animation = x.startAnimation
				break
	Data.money += 0
	self.queue_free()
