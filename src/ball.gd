extends KinematicBody2D

onready var timer = $Timer
var speed: int = 200
var level: int = 1
var existence_length: int = 0
var _rng = RandomNumberGenerator.new()

func _ready() -> void:
	Data.number_of_balls += 1
	_rng.randomize()
	respawn()

func respawn() -> void: # Used to respawn the ball at the starting location
	Data.connect("update_game_interface", self, "update_speed")
	update_speed()
	if existence_length > 0: # Makes sure that the timer is at the start
		timer.stop()
		timer.wait_time = existence_length
		timer.start()
		self.modulate = Color("b71515")
	# Sets a random rotation and moves a little away from the center
	var _rotation = _rng.randf() * 360
	self.position.x = 512
	self.position.y = 300
	self.rotation_degrees = _rotation
	move_and_slide_angles(fix_rotation_calculation(self.rotation), 60, 1)


# Stolen code
func fix_rotation_calculation(angle: float) -> float: # Used to fix the calculation of the self.rotation_degrees
	return (angle * -1 + 3.14159265/2)

func move_and_slide_angles(angle: float, speed: float, delta: float) -> Array: # move and slide but with angle support and returns new speed, angle, and collisions
	var _velocity = calcVelcoity(angle, speed)*delta
	var _correction = move_and_collide(_velocity)
	var _test = _velocity
	if _correction: # Adds 1 money if collision detected
		Data.money += 1
	_velocity =  _velocity.bounce(_correction.normal) if _correction else _velocity
	angle = _velocity.angle() + 3.141592/2
	return [_velocity.length()/delta if speed > 0 else -1 * _velocity.length()/delta, angle if speed > 0 else angle - 3.1415, _correction]	

func calcVelcoity(angle: float, speed: float) -> Vector2: # calculates the velocity with angles and speed
	return Vector2( cos(angle) * speed, -sin(angle) * speed)
# End of stolen code


func _physics_process(delta: float) -> void: # Makes sure to move the ball and bounce it of the edges
	var _result = move_and_slide_angles(fix_rotation_calculation(self.rotation), speed, delta)
	self.rotate(-self.rotation)
	self.rotate(_result[1])

func _on_doubler_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void: # Checks if the doubler was hit
	if existence_length == 0 or Data.duplicaters_duplicate:
		if Data.number_of_balls < 150: # Makes sure there are not to many balls
			respawn() # Respawns
			# Spawns a new ball
			var _instance = load("res://src/ball.tscn")
			_instance = _instance.instance()
			_instance.speed = speed
			_instance.level = level
			_instance.existence_length = 15
			get_node("/root/Main/Game Field").call_deferred("add_child", _instance)

func _on_Timer_timeout() -> void: # Ball disappear after timer times out
	Data.number_of_balls -= 1
	self.queue_free()

func update_speed() -> void: # Recalculates the speed when needed
	speed = Data.balls[level - 1][0] * Data.speed_multiplier
