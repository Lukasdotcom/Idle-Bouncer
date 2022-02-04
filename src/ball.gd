extends KinematicBody2D

export var speed: int = 10
var _rng = RandomNumberGenerator.new()

func _ready() -> void:
	_rng.randomize()
	respawn()

func respawn(reset: bool=false) -> void: # Used to respawn the ball at the starting location
	if reset: # Checks if the coins should be reset
		Data.reset_coins()
	# Sets a random rotation and moves a little away from the center
	var _rotation = _rng.randf() * 360
	self.position.x = 512
	self.position.y = 300
	self.rotation_degrees = _rotation
	move_and_slide_angles(fix_rotation_calculation(self.rotation), 50, 1)

# Stolen code
func fix_rotation_calculation(angle: float) -> float: # Used to fix the calculation of the self.rotation_degrees
	return (angle * -1 + 3.14159265/2)

func move_and_slide_angles(angle: float, speed: float, delta: float) -> Array: # move and slide but with angle support and returns new speed, angle, and collisions
	var _velocity = calcVelcoity(angle, speed)*delta
	var _correction = move_and_collide(_velocity)
	var _test = _velocity
	_velocity =  _velocity.bounce(_correction.normal) if _correction else _velocity
	angle = _velocity.angle() + 3.141592/2
	return [_velocity.length()/delta if speed > 0 else -1 * _velocity.length()/delta, angle if speed > 0 else angle - 3.1415, _correction]	

func calcVelcoity(angle: float, speed: float) -> Vector2: # calculates the velocity with angles and speed
	return Vector2( cos(angle) * speed, -sin(angle) * speed)
# End of stolen code

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("respawn"):
		Data.money += 1
		respawn(true)
	var _result = move_and_slide_angles(fix_rotation_calculation(self.rotation), speed, delta)
	self.rotate(-self.rotation)
	self.rotate(_result[1])

func _on_doubler_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void: # Checks if the doubler was hit
	Data.coins *= 2
	respawn()
