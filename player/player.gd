extends CharacterBody2D


@export_subgroup("Energy")
@export var max_energy : float = 100.0
@export var energy_regen_speed : float = 0.5

@export_subgroup("Moving")
@export var speed : float = 300.0

@export_subgroup("Flying")
@export var fly_height : float = 50.0
@export var fly_duraction_sec : float = 1.0
@export var fly_distance : float = 150.0
@export var fly_height_curve : Curve

signal energy_runout

enum State {
	NONE,
	MOVING,
	FLYING,
	DASHING
}


var height : float : 
	get:
		return _height

var energy : float :
	get:
		return _energy

var _state : State = State.MOVING

var _ghost : bool = false # no damage and ignore obsctacles
var _energy : float = max_energy
var _moving_direction : Vector2
var _height : float = 0.0

var _collision_layer_buffer : int
var _collision_mask_buffer : int

# flying state data
var _flying_time : float
var _initial_flying_local_position : Vector2
var _finish_flying_local_position : Vector2


func play_death() -> void:
	%AnimationPlayer.play("death")


func play_win() -> void:
	%AnimationPlayer.play("win")


func play_energy_buff() -> void:
	%AnimationPlayer.play("energy_buff")


func proceed_collision_area(collision_area:Area2D) -> void:
	pass


func _process(delta: float) -> void:
	_energy = clamp(_energy+energy_regen_speed*delta, 0.0, max_energy)
	%EnergyLabel.text = "energy %.0f" % _energy
	
	match _state:
		State.MOVING:
			_process_moving(delta)
		State.FLYING:
			_process_flying(delta)
		State.DASHING:
			_process_dashing(delta)


func _process_moving(delta:float) -> void:
	_moving_direction = Input.get_vector("A", "D", "W", "S")
	velocity = _moving_direction * speed
	
	if Input.is_action_just_pressed("player_fly_ability"):
		_state_flying(_moving_direction)


func _process_flying(delta:float) -> void:
	_flying_time += delta
	if _flying_time >= fly_duraction_sec:
		_state_moving()
		return
	
	var dashing_progress : float = _flying_time / fly_duraction_sec
	
	_set_height(fly_height_curve.sample_baked(dashing_progress)*fly_height)
	position = lerp(_initial_flying_local_position, _finish_flying_local_position, dashing_progress)


func _process_dashing(delta:float) -> void:
	pass


func _physics_process(delta: float):
	move_and_slide()


func _set_ghost(is_ghost:bool) -> void:
	if is_ghost:
		_ghost = true
		collision_layer = _collision_layer_buffer
		collision_mask = _collision_mask_buffer
	else:
		_ghost = false
		_collision_layer_buffer = collision_layer
		_collision_mask_buffer = collision_mask
		collision_layer = 0
		collision_mask = 0


func _set_height(new_height:float) -> void:
	_height = new_height
	%EnergyBall.position.y = -_height


func _state_moving() -> void:
	_set_ghost(false)
	_set_height(0.0)
	_state = State.MOVING


func _state_flying(dashing_direction:Vector2) -> void:
	_set_ghost(true)
	_initial_flying_local_position = position
	_finish_flying_local_position = position + dashing_direction.normalized()*fly_distance
	_flying_time = 0.0
	velocity = Vector2.ZERO
	_state = State.FLYING


func _state_dashing() -> void:
	_state = State.DASHING
