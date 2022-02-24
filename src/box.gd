extends Node2D
onready var animation = $AnimationPlayer

var level: int = 1
var startAnimation: float = 0
var id = [0, 1]
var disabled = false
var invisible = false
onready var game = get_node("/root/Main/Game Field")

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
	game.enabled += 1
	game.visibly += 1
	game.total += 1
	game.connect("update", self, "update")
	update()

func _on_hit(body: Node) -> void:
	var _earnings = Data.earnings[level] + (game.disabledTotal / game.enabled) # Calculates the base earnings
	_earnings *=  Data.multiplier # Multiplies the global multiplier
	_earnings *= body.multiplier # Multiplies the balls multiplier
	_earnings = ceil(_earnings)
	Data.money += _earnings
	get_node("../../MPS Calculator").earnings(_earnings)

func delete() -> void: # Used to delete the box
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
	# Resets the stats for the box counter
	if not invisible:
		game.visibly -= 1
	if not disabled:
		game.enabled -= 1
	game.total -= 1
	self.queue_free()

func update() -> void: # Does all the neccessaary hiding and disabling of physics.
	if disabled: # Sets physics
		if game.enabled / game.total < game.simulate or game.simulate == 1:
			game.enabled += 1
			game.disabledTotal -= Data.earnings[level]
			disabled = false
			$Node2D/Area2D.collision_mask = 2
	else:
		if game.enabled / game.total > game.simulate and game.enabled > 1:
			game.enabled -= 1
			game.disabledTotal += Data.earnings[level]
			disabled = true
			$Node2D/Area2D.collision_mask = 0
	if invisible: # Sets visibility
		if (game.visibly + 1) / game.total < game.show or game.show == 1:
			game.visibly += 1
			invisible = false
	else:
		if game.visibly / game.total > game.show:
			game.visibly -= 1
			invisible = true
	var _visibilty = true
	# Makes sure to set the visibilty according to the right setting
	if game.onlySimulate:
		_visibilty = not disabled
	else:
		_visibilty = not invisible
	if _visibilty:
		self.show()
	else:
		self.hide()
