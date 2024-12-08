extends CharacterBody2D

@export var bullet_container : Node

@export_subgroup("Energy")
@export var max_energy : float = 100.0
@export var energy_regen_speed : float = 0.5
@export var flying_energy_cost : float = 30.0
@export var dashing_energy_cost : float = 80.0
@export var shoot_energy_cost : float = 1.0
@export var min_energy_message_show_1 : float = 30.0
@export var min_energy_message_show_2 : float = 20.0
@export var min_energy_message_show_3 : float = 10.0

@export_subgroup("Moving")
@export var speed : float = 300.0

@export_subgroup("Flying")
@export var fly_height : float = 50.0
@export var fly_duraction_sec : float = 1.0
@export var fly_distance : float = 150.0
@export var fly_height_curve : Curve

@export_subgroup("Dashing")
@export var dash_distance : float = 250.0
@export var dash_duration_sec : float = 0.4

signal energy_runout
signal energy_level_changed(new_level:PlayerNamespace.EnergyLevel)

enum State {
	NONE,
	MOVING,
	FLYING,
	DASHING,
	OUT_OF_ENERGY,
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
var _energy_level : PlayerNamespace.EnergyLevel = PlayerNamespace.EnergyLevel.HIGH

# flying state data
var _flying_time : float
var _initial_flying_global_position : Vector2
var _finish_flying_global_position : Vector2


# dashing state data
var _dasing_time : float 
var _initial_dashing_global_position : Vector2
var _finish_dashing_global_position : Vector2
var _dashed_rids : Array[RID] = []


@export_category("message_energy")
@export var energy_low  : Polygon2D
@export var energy_low_label : Label

func play_death() -> void:
	%AnimationPlayer.play("death")


func play_win() -> void:
	%AnimationPlayer.play("win")


func play_energy_buff() -> void:
	%AnimationPlayer.play("energy_buff")


func take_damage(damage:float) -> void:
	_change_energy(-damage)


func take_heal(healing:float) -> void:
	_change_energy(healing)


func _process(delta: float) -> void:
	_change_energy(energy_regen_speed*delta)
	
	%EnergyLabel.text = "energy %.0f" % _energy
	
	match _state:
		State.MOVING:
			_process_moving(delta)
		State.FLYING:
			_process_flying(delta)
		State.DASHING:
			_process_dashing(delta)


func _process_moving(delta:float) -> void:
	const BULLET_SCENE : PackedScene = preload(ScenesNamespace.PLAYER_BULLET_FILEPATH)
	
	_moving_direction = Input.get_vector("A", "D", "W", "S")
	velocity = _moving_direction * speed
	
	if Input.is_action_just_pressed("player_fly_ability"):
		_state_flying(_moving_direction)
	
	if Input.is_action_just_pressed("player_dash_ability"):
		if _moving_direction.length() >= 0.01:
			_state_dashing(_moving_direction)
	
	if Input.is_action_just_pressed("shoot_down"):
		_change_energy(-shoot_energy_cost)
		var bullet : Node2D = BULLET_SCENE.instantiate()
		bullet.flying_direction = Vector2.DOWN
		bullet.global_position = global_position
		bullet.excludes.append(get_rid())
		bullet_container.add_child(bullet)
	
	if Input.is_action_just_pressed("shoot_left"):
		_change_energy(-shoot_energy_cost)
		var bullet : Node2D = BULLET_SCENE.instantiate()
		bullet.flying_direction = Vector2.LEFT
		bullet.global_position = global_position
		bullet.excludes.append(get_rid())
		bullet_container.add_child(bullet)
	
	if Input.is_action_just_pressed("shoot_right"):
		_change_energy(-shoot_energy_cost)
		var bullet : Node2D = BULLET_SCENE.instantiate()
		bullet.flying_direction = Vector2.RIGHT
		bullet.global_position = global_position
		bullet.excludes.append(get_rid())
		bullet_container.add_child(bullet)
	
	if Input.is_action_just_pressed("shoot_up"):
		_change_energy(-shoot_energy_cost)
		var bullet : Node2D = BULLET_SCENE.instantiate()
		bullet.flying_direction = Vector2.UP
		bullet.global_position = global_position
		bullet.excludes.append(get_rid())
		bullet_container.add_child(bullet)


func _process_flying(delta:float) -> void:
	const BOMB_SCENE : PackedScene = preload(ScenesNamespace.PLAYER_BOMB_FILEPATH)
	
	_flying_time += delta
	if _flying_time >= fly_duraction_sec:
		global_position = _finish_flying_global_position
		_state_moving()
		return
	
	if Input.is_action_just_pressed("player_bomb_action"):
		_change_energy(shoot_energy_cost)
		var bullet : Node2D = BOMB_SCENE.instantiate()
		bullet.height = _height
		bullet.global_position = Vector2(global_position.x, global_position.y-_height)
		bullet.excludes.append(get_rid())
		bullet_container.add_child(bullet)
	
	var flying_progress : float = _flying_time / fly_duraction_sec
	
	_set_height(fly_height_curve.sample_baked(flying_progress)*fly_height)
	global_position = lerp(_initial_flying_global_position, _finish_flying_global_position, flying_progress)


func _process_dashing(delta:float) -> void: 
	_dasing_time += delta
	if _dasing_time >= dash_duration_sec:
		if _slice_between_points(global_position, _finish_dashing_global_position):
			global_position = _finish_dashing_global_position
		_state_moving()
		return
	
	var dashing_progress : float = _dasing_time / dash_duration_sec
	var next_pos : Vector2 = lerp(_initial_dashing_global_position, _finish_dashing_global_position, dashing_progress)
	if _slice_between_points(global_position, next_pos):
		global_position = next_pos


func _physics_process(delta: float):
	move_and_slide()


func _set_ghost(is_ghost:bool) -> void:
	%EnergyBallShape.set_deferred("disabled", is_ghost)


func _change_energy(amount:float) -> void:
	_energy = clamp(_energy+amount, 0.0, max_energy)
	
	if _energy == 0.0: # тут сравнение флоатов допустимо, т.к. clamp вернет точно 0.0 и ничего другого
		energy_runout.emit()
	
	var updated_energy_level : PlayerNamespace.EnergyLevel = _calc_energy_level()
	if updated_energy_level != _energy_level:
		_energy_level = updated_energy_level
		energy_level_changed.emit(_energy_level)


func _set_height(new_height:float) -> void:
	_height = new_height
	%EnergyBall.position.y = -_height


func _state_moving() -> void:
	_set_ghost(false)
	_set_height(0.0)
	_state = State.MOVING


func _state_flying(flying_direction:Vector2) -> void:
	_change_energy(-flying_energy_cost)
	_set_ghost(true)
	_initial_flying_global_position = global_position
	_finish_flying_global_position = global_position + flying_direction.normalized()*fly_distance
	_flying_time = 0.0
	velocity = Vector2.ZERO
	_state = State.FLYING


func _state_dashing(dashing_direction:Vector2) -> void:
	_change_energy(-dashing_energy_cost)
	_set_ghost(true)
	_initial_dashing_global_position = global_position
	_finish_dashing_global_position = global_position + dashing_direction.normalized()*dash_distance
	_dasing_time = 0.0
	velocity = Vector2.ZERO
	_dashed_rids = []
	_state = State.DASHING


func _slice_between_points(start:Vector2, end:Vector2) -> bool: # returns true if continue dashing
	var intersect_parameters : PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.new()
	intersect_parameters.from = start
	intersect_parameters.to = end
	intersect_parameters.exclude = [get_rid()] + _dashed_rids

	var collision : Dictionary = \
		PhysicsServer2D.space_get_direct_state(get_world_2d().space).intersect_ray(intersect_parameters)
	
	while not collision.is_empty():
		if not _process_dash_sliced_object(collision["collider"]):
			global_position = collision["position"] - (end-start).normalized()*%EnergyBallShape.shape.radius
			return false
		
		_dashed_rids.append(collision["rid"])
		intersect_parameters.exclude = [get_rid()] + _dashed_rids
		collision = PhysicsServer2D.space_get_direct_state(get_world_2d().space).intersect_ray(intersect_parameters)
	
	return true


func _process_dash_sliced_object(object:Object) -> bool:
	if object is CollisionObject2D:
		print(object.name) 
		
		if object.is_in_group(GroupsNamespace.DESTRUCTABLE_OBJECT):
			object.queue_free()
		elif object.is_in_group(GroupsNamespace.DAMAGABLE):
			object.take_damage(9999999999.0)
		else:
			_state_moving.call_deferred()
			return false
	
	return true


func _calc_energy_level() -> PlayerNamespace.EnergyLevel:
	var norm_energy : float = _energy / max_energy
	
	if norm_energy < 0.2:
		return PlayerNamespace.EnergyLevel.LOWLOW
	
	if norm_energy < 0.4:
		return PlayerNamespace.EnergyLevel.LOW
	
	if norm_energy < 0.8:
		return PlayerNamespace.EnergyLevel.NORMAL
	
	return PlayerNamespace.EnergyLevel.HIGH


func _on_energy_runout() -> void:
	_state = State.NONE
	var scene : PackedScene = preload("res://scenes/game_over.tscn")
	await get_tree().create_timer(2).timeout
	get_tree().change_scene_to_packed(scene)
